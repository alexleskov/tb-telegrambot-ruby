# frozen_string_literal: true

require './models/profile'
require './models/course_session'
require './models/section'
require './models/material'
require './models/quiz'
require './models/scorm_package'
require './models/task'
require './models/attachment'
require './models/answer'
require './models/comment'
require './models/cache_message'
require './lib/attribute'

module Teachbase
  module Bot
    class DataLoader
      include Formatter

      MAX_RETRIES = 3
      CS_STATES = %i[active archived].freeze
      MAIN_OBJECTS_CUSTOM_PARAMS = { users: { "name" => :first_name },
                                     course_sessions: { "updated_at" => :changed_at } }.freeze
      CONTENT_VIDEO_FORMAT = "mp4"
      ADDTION_OBJECTS = { attachments: :attachment,
                          answers: :answer,
                          blocks: :block,
                          comments: :comment }.freeze

      attr_reader :appshell

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @logger = AppConfigurator.new.load_logger
        @retries = 0
      end

      def call_profile
        call_data do
          lms_info = appshell.authsession.load_profile
          raise "Profile is not loaded" unless lms_info

          user_attrs = Attribute.create(Teachbase::Bot::User.attribute_names, lms_info,
                                        MAIN_OBJECTS_CUSTOM_PARAMS[:users])
          user_attrs[:tb_id] = lms_info["id"]
          profile_attrs = Attribute.create(Teachbase::Bot::Profile.attribute_names, lms_info)
          appshell.user.update!(user_attrs)
          Teachbase::Bot::Profile.find_or_create_by!(user_id: appshell.user.id).update!(profile_attrs)
        end
      end

      def call_cs_list(params)
        state = params[:state]
        raise "No such option for update course sessions list" unless CS_STATES.include?(state.to_sym)

        limit_count = params[:limit]
        offset_num = params[:offset]
        mode = params[:mode] || :normal
        result = []
        call_data do
          delete_course_sessions(state) if mode == :with_reload
          lms_info = appshell.authsession.load_course_sessions(state)
          ind = offset_num || 0
          stop_ind = limit_count ? offset_num + limit_count : lms_info.size - 1
          loop do
            course_session_lms = lms_info[ind]
            cs = appshell.user.course_sessions.find_or_create_by!(tb_id: course_session_lms["id"])
            cs_attrs = Attribute.create(Teachbase::Bot::CourseSession.attribute_names, course_session_lms,
                                        MAIN_OBJECTS_CUSTOM_PARAMS[:course_sessions])
            cs_attrs[:status] = state.to_s
            cs.update!(cs_attrs)
            ind += 1
            result << cs.id
            break if ind == stop_ind + 1 || lms_info[ind].nil?
          end
        end
        result
      end

      def call_cs_info(cs_tb_id)
        call_update_cs(cs_tb_id) { appshell.authsession.load_cs_info(cs_tb_id) }
      end

      def call_cs_progress(cs_tb_id)
        lms_info = call_data { appshell.authsession.load_cs_progress(cs_tb_id) }
        cs = call_update_cs(cs_tb_id) { lms_info }
        return appshell.user.course_sessions.find_by(tb_id: cs_tb_id) unless cs

        Teachbase::Bot::Section::OBJECTS_TYPES.keys.each do |content_type|
          lms_info[content_type.to_s].each do |content_lms|
            content_db = cs.public_send(content_type).find_by(tb_id: content_lms["id"])
            next unless content_db

            content_db.update!(Attribute.create(section_content_attrs(content_type), content_lms))
          end
        end
        cs
      end

      def call_cs_sections(cs_tb_id)
        call_data do
          return if course_session_last_version?(cs_tb_id) && !course_session_last_version?(cs_tb_id).sections.empty?

          cs = appshell.user.course_sessions.find_by!(tb_id: cs_tb_id)
          cs&.sections&.destroy_all
          appshell.authsession.load_cs_info(cs_tb_id)["sections"].each_with_index do |section_lms, ind|
            section_bd = cs.sections.find_or_create_by!(position: ind + 1, user_id: appshell.user.id)
            section_attrs = Attribute.create(Teachbase::Bot::Section.attribute_names, section_lms)
            section_bd.update!(section_attrs)
          end
        end
      end

      def call_cs_sec_contents(section_bd)
        raise unless section_bd.is_a?(Teachbase::Bot::Section)

        call_data do
          cs_data_lms = appshell.authsession.load_cs_info(section_bd.course_session.tb_id)
          section_lms = cs_data_lms["sections"][section_bd.position - 1]
          Teachbase::Bot::Section::OBJECTS.each do |type|
            section_bd.public_send(type).destroy_all
            next if section_lms[type.to_s].empty?

            fetch_section_objects(type, section_lms, section_bd)
          end
        end
      end

      def call_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
        section_bd = appshell.user.sections_by_cs_tbid(cs_tb_id).find_by(id: sec_id)
        raise unless section_bd || section_bd.empty?

        call_data do
          lms_data = appshell.authsession.load_content(content_type, cs_tb_id, content_tb_id)
          if lms_data["type"] == "video" && lms_data["source"].is_a?(Hash)
            lms_data["source"] = lms_data["source"][CONTENT_VIDEO_FORMAT]
          end
          @logger.debug "lms_data: #{lms_data}"
          content = section_bd.public_send(content_type).find_by!(tb_id: content_tb_id)
          content.update!(Attribute.create(section_content_attrs(content_type), lms_data))
          ADDTION_OBJECTS.keys.each do |addition_object|
            attach_addition_object(addition_object, content, lms_data)
          end
          content
        end
      end

      def call_track_material(cs_tb_id, material_tb_id, time_spent)
        material = appshell.user.material_by_cs_tbid(cs_tb_id, material_tb_id)
        raise unless material

        call_data do
          time = appshell.authsession.track_material(cs_tb_id, material_tb_id, time_spent)
          raise unless time

          material.update!(time_spent: time)
        end
        material
      end

      def delete_course_sessions(state)
        appshell.user.course_sessions.where(status: state.to_s).destroy_all
      end

      private

      def attach_addition_object(addition_object, content, lms_data)
        return unless addition_object?(lms_data, addition_object)

        lms_data[addition_object.to_s].each do |data_lms|
          data_type_class = to_constantize(to_camelize(addit_data_sign(addition_object)), "Teachbase::Bot::")
          attributes = Attribute.create(data_type_class.attribute_names, data_lms)
          attributes[:tb_id] = data_lms["id"] if data_lms["id"]
          addition_data_bd = content.public_send(addition_object).find_or_create_by!(attributes)
          if data_lms.keys.any? { |key| ADDTION_OBJECTS.include?(key.to_sym) }
            ADDTION_OBJECTS.keys.each do |sub_addition_object|
              attach_addition_object(sub_addition_object, addition_data_bd, data_lms)
            end
          end
        end
      end

      def addition_object?(lms_data, addition_object)
        lms_data.keys.include?(addition_object.to_s) && !lms_data[addition_object.to_s].empty?
      end

      def addit_data_sign(addition_object)
        (ADDTION_OBJECTS[addition_object.to_sym]).to_s
      end

      def call_data
        return unless appshell.access_mode == :with_api

        appshell.user
        yield
      rescue RuntimeError => e
        if e.http_code == 401 || e.http_code == 403
          retry
        elsif (@retries += 1) <= MAX_RETRIES
          @logger.debug "#{e}\n#{I18n.t('retry')} №#{@retries}.."
          sleep(@retries)
          retry
        else
          @logger.debug "Unexpected error after retries: #{e}. code: #{e.http_code}"
        end
      end

      def call_update_cs(cs_tb_id)
        call_data do
          cs = appshell.user.course_sessions.find_by!(tb_id: cs_tb_id)
          lms_info = yield
          cs_attrs = Attribute.create(Teachbase::Bot::CourseSession.attribute_names, lms_info,
                                      MAIN_OBJECTS_CUSTOM_PARAMS[:course_sessions])
          cs.update!(cs_attrs)
          cs
        end
      end

      def course_session_last_version?(cs_tb_id)
        appshell.user.course_sessions.find_by(tb_id: cs_tb_id, changed_at: call_cs_info(cs_tb_id).changed_at)
      end

      def fetch_section_objects(content_type, section_lms, section_bd)
        raise "No such content type: #{content_type}." unless section_bd.respond_to?(content_type)

        content_params = section_content_attrs(content_type)
        section_lms[content_type.to_s].each do |content_type_hash|
          attributes = Attribute.create(content_params, content_type_hash,
                                        Teachbase::Bot::Section::OBJECTS_CUSTOM_PARAMS[content_type])
          section_bd.public_send(content_type).find_or_create_by!(position: content_type_hash["position"],
                                                                  tb_id: content_type_hash["id"],
                                                                  user_id: appshell.user.id,
                                                                  course_session_id: section_bd.course_session.id)
                    .update!(attributes)
        end
      end

      def section_content_attrs(content_type)
        to_constantize(to_camelize(Teachbase::Bot::Section::OBJECTS_TYPES[content_type.to_sym]),
                       "Teachbase::Bot::").public_send(:attribute_names)
      end
    end
  end
end
