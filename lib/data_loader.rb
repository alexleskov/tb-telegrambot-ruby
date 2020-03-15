#require './models/user'
#require './models/api_token'
require './models/profile'
require './models/course_session'
require './models/section'
require './models/material'
require './models/quiz'
require './models/scorm_package'
require './models/task'

module Teachbase
  module Bot
    class DataLoader
      include Formatter

      MAX_RETRIES = 3
      CS_STATES = %i[active archived].freeze
      SECTION_OBJECTS = [ :materials, :scorm_packages, :quizzes, :tasks ].freeze
      SECTION_OBJECTS_CUSTOM_PARAMS = { materials: { "type" => :content_type },
                                        scorm_packages: { "title" => :name } }.freeze
      MAIN_OBJECTS_CUSTOM_PARAMS = { users: { "name" => :first_name },
                                     course_sessions: { "updated_at" => :changed_at } }.freeze
      SECTION_OBJECT_TYPES = { materials: :material,
                       scorm_packages: :scorm_package,
                       quizzes: :quiz,
                       tasks: :task}
      CONTENT_VIDEO_FORMAT = "mp4".freeze

      attr_reader :user, :authsession

      def initialize(appshell)
        raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
        @logger = AppConfigurator.new.get_logger
        @retries = 0
      end

      def get_cs_info(cs_id)
        get_data { user.course_sessions.find_by(tb_id: cs_id) }
      end

      def get_user_profile
        get_data { user.profile }
      end

      def get_cs_list(state, limit_count, offset_num)
        get_data { user.course_sessions.order(name: :asc).limit(limit_count).offset(offset_num).where(complete_status: state.to_s,
                                                     scenario_mode: @appshell.settings.scenario) }
      end

      def get_cs_sections(cs_id)
        get_data { get_cs_info(cs_id).sections.order(position: :asc) }
      end

      def get_cs_sec_by(option, param, cs_id)
        get_data do
          case option
          when :position
            user.course_sessions.find_by(tb_id: cs_id).sections.find_by(position: param)
          when :id
            user.course_sessions.find_by(tb_id: cs_id).sections.find_by(id: param)
          end
        end
      end

      def get_cs_sec_contents(section_bd)
        return unless section_bd

        section_objects = {}
        get_data do
          SECTION_OBJECTS.each do |content_type|
            section_objects[content_type] = section_bd.public_send(content_type).order(position: :asc)
          end
        end
        section_objects
      end

      def get_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
        get_data do
          user.course_sessions.find_by(tb_id: cs_tb_id)
              .sections.find_by(id: sec_id)
              .public_send(content_type).find_by(tb_id: content_tb_id)
        end
      end

      def call_profile
        call_data do
          lms_info = authsession.load_profile
          raise "Profile is not loaded" unless lms_info

          profile = Teachbase::Bot::Profile.find_or_create_by!(user_id: user.id)
          user_params = create_attributes(Teachbase::Bot::User.attribute_names, lms_info, MAIN_OBJECTS_CUSTOM_PARAMS[:users])
          user_params[:tb_id] = lms_info["id"]
          profile_params = create_attributes(Teachbase::Bot::Profile.attribute_names, lms_info)
          user.update!(user_params)
          profile.update!(profile_params)
        end
      end

      def call_cs_list(state, mode = :normal)
        raise "No such option for update course sessions list" unless CS_STATES.include?(state.to_sym)
        
        delete_course_sessions(state) if mode == :with_reload

        call_data do
          lms_info = authsession.load_course_sessions(state)
          #@logger.debug "lms_info: #{lms_info}"

          lms_info.each do |course_session_lms|
            cs = user.course_sessions.find_or_create_by!(tb_id: course_session_lms["id"])
            course_session_params = create_attributes(Teachbase::Bot::CourseSession.attribute_names,
                                                      course_session_lms,
                                                      MAIN_OBJECTS_CUSTOM_PARAMS[:course_sessions])
            course_session_params[:complete_status] = state.to_s
            cs.update!(course_session_params)
          end
        end
      end

      def call_cs_info(cs_id)
        call_data do
          cs = user.course_sessions.find_by!(tb_id: cs_id)
          lms_info = authsession.load_cs_info(cs_id)
          course_session_params = create_attributes(Teachbase::Bot::CourseSession.attribute_names,
                                                    lms_info,
                                                    MAIN_OBJECTS_CUSTOM_PARAMS[:course_sessions])
          cs.update!(course_session_params)
          cs
        end
      end

      def call_cs_sections(cs_id)
        call_data do
          return if course_session_last_version?(cs_id) && !course_session_last_version?(cs_id).sections.empty?

          cs = user.course_sessions.find_by!(tb_id: cs_id)
          cs.sections.destroy_all if cs

          #@request_loader = Async do |task|
            authsession.load_cs_info(cs_id)["sections"].each_with_index do |section_lms, ind|
              section_bd = cs.sections.find_or_create_by!(position: ind + 1, user_id: user.id)
              SECTION_OBJECTS.each do |type|
                fetch_section_objects(type, section_lms, section_bd)
              end
              section_params = create_attributes(Teachbase::Bot::Section.attribute_names, section_lms)
              section_bd.update!(section_params)
            end
          #end
        end
      end

      def call_cs_sec_content(content_type, cs_tb_id, sec_id, content_tb_id)
        section_bd = get_cs_sec_by(:id, sec_id, cs_tb_id)
        call_data do
          case content_type.to_sym
          when :materials
            lms_data = authsession.load_material(cs_tb_id, content_tb_id)
            @logger.debug "lms_data: #{lms_data}"

            attributes = fetch_content_material(lms_data)
            section_bd.materials.find_by!(tb_id: content_tb_id).update!(attributes)
          when :tasks
            # TO DO: Some logic
          when :quizzes
            # TO DO: Some logic
          when :scorm_packages
            # TO DO: Some logic
          else
            raise "Can't open such content type: '#{content_type}'"
          end
        end
      end

      def delete_course_sessions(state)
        get_data do
          user.course_sessions.where(complete_status: state.to_s).destroy_all
        end
      end

      private

      def get_data
        @authsession = @appshell.authorizer.call_authsession(:without_api)
        @user = authsession.user
        yield
      end

      def call_data
        @authsession = @appshell.authorizer.call_authsession(:with_api)
        @user = authsession.user
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

      def course_session_last_version?(cs_id)
        user.course_sessions.find_by(tb_id: cs_id, changed_at: call_cs_info(cs_id).changed_at)
      end

      def fetch_content_material(material_lms)
        attributes = {}

        case material_lms["type"]
        when "video"
          attributes = { source: material_lms["source"][CONTENT_VIDEO_FORMAT] }
        when "vimeo", "youtube", "image", "audio", "pdf", "iframe"
          attributes = create_attributes(%w[source], material_lms)
        when "text"
            attributes = create_attributes(%w[content], material_lms)
          if material_lms["editor_js"]
            attributes[:editor_js] = material_lms["editor_js"]
          elsif material_lms["markdown"]
            attributes[:markdown] = material_lms["markdown"]
          end
        else 
          raise "Can't fetch such material type: '#{material_lms["type"]}'"
        end
        attributes
      end

      def create_attributes(params, object_type_hash, custom_params = {})
        raise "Params must be an Array. Your params: #{params} is #{params.class}." unless params.is_a?(Array)

        attributes = {}
        replace_key_names(custom_params, object_type_hash) if custom_params && !custom_params.empty?
        params.each do |param|
          if !object_type_hash[param.to_s].nil? && ![:id, :position].include?(param.to_sym)
            attributes[param.to_sym] = object_type_hash[param.to_s]
          end
        end
        attributes
      end

      def fetch_section_objects(conten_type, section_lms, section_bd)
        raise "No such content type: #{conten_type}." unless section_bd.respond_to?(conten_type)

        content_params = to_constantize(to_camelize(SECTION_OBJECT_TYPES[conten_type]), "Teachbase::Bot::")
                                 .public_send(:attribute_names)
        cs_id = section_bd.course_session.id        
        section_lms[conten_type.to_s].each do |content_type_hash|
          attributes = create_attributes(content_params, content_type_hash, SECTION_OBJECTS_CUSTOM_PARAMS[conten_type])
          section_bd.public_send(conten_type)
                    .find_or_create_by!(position: content_type_hash["position"],
                                        tb_id: content_type_hash["id"],
                                        user_id: user.id,
                                        course_session_id: cs_id)
                    .update!(attributes)
        end
      end

      def replace_key_names(mapping, initial_hash)
        mapping.each do |old_key, new_key|
          initial_hash[new_key.to_s] = initial_hash.delete(old_key)
        end
      end
    end
  end
end


