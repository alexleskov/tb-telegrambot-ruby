# frozen_string_literal: true

module Teachbase
  module Bot
    class SectionLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = {}.freeze

      attr_reader :lms_info, :option, :value, :cs_tb_id

      def initialize(appshell, params)
        @option = params[:option]
        @value = params[:value]
        @cs_tb_id = params[:cs_tb_id]
        raise "Must be set up 'option' and 'cs_tb_id" unless cs_tb_id && option

        super(appshell)
      end

      def contents
        return unless db_entity || db_entity.empty?
        
        lms_load(data: :info)
        with_content_types(:destroy_all) { build_content_objects }
      end

      def progress
        return unless db_entity || db_entity.empty?

        lms_load(data: :contents_progress)
        with_content_types(:none) { update_content_objects }
      end

      def content
        Teachbase::Bot::ContentLoaders.new(appshell, self)
      end

      def db_entity(mode = :no_create)
        raise "No such option: '#{option}" unless %i[position id].include?(option.to_sym)

        call_data do
          case mode
          when :with_create
            model_class.find_or_create_by!(option.to_sym => value, user_id: appshell.user.id, course_session_id: cs_id)
          else
            model_class.find_by(option.to_sym => value, user_id: appshell.user.id, course_session_id: cs_id)
          end
        end
      end

      def model_class
        Teachbase::Bot::Section
      end

      private

      def with_content_types(mode, &block)
        model_class::OBJECTS_TYPES.keys.each do |content_type|
          raise "No such content type: #{content_type}." unless db_entity.respond_to?(content_type)
          raise "Can't find lms_info. Given: '#{lms_info}'" unless lms_info

          @content_type = content_type
          @content_params = build_content_attrs(content_type)
          db_entity.public_send(content_type).destroy_all if mode == :destroy_all
          next if lms_info[content_type.to_s].empty?
          yield
        end
      end

      def cs_id
        Teachbase::Bot::CourseSession.find_by(tb_id: cs_tb_id).id
      end

      def init_cs_loader
        Teachbase::Bot::CourseSessionLoader.new(appshell, tb_id: cs_tb_id)
      end

      def lms_load(options)
        @lms_info = call_data do
                      case options[:data].to_sym
                      when :listing
                        init_cs_loader.send(:lms_load, data: :sections)
                      when :info
                        lms_load(data: :listing)[db_entity.position - 1]
                      when :contents_progress
                        init_cs_loader.send(:lms_load, data: :progress)
                      else
                        raise "Can't call such data: '#{options[:data]}'"
                      end
                    end
      end

      def update_content_objects
        lms_info[@content_type.to_s].each do |content_lms|
          content_db = db_entity.public_send(@content_type).find_by(tb_id: content_lms["id"])
          next unless content_db
          attributes = Attribute.create(@content_params, content_lms, model_class::OBJECTS_CUSTOM_PARAMS[@content_type])
          content_db.update!(attributes)
        end
      end

      def build_content_objects
        lms_info[@content_type.to_s].each do |content_lms|
          attributes = Attribute.create(@content_params, content_lms, model_class::OBJECTS_CUSTOM_PARAMS[@content_type])
          db_entity.public_send(@content_type).find_or_create_by!(position: content_lms["position"],
                                                                  tb_id: content_lms["id"],
                                                                  user_id: appshell.user.id,
                                                                  course_session_id: cs_id).update!(attributes)
        end
      end

      def build_content_attrs(content_type)
        to_constantize(to_camelize(Teachbase::Bot::Section::OBJECTS_TYPES[content_type.to_sym]),
                       "Teachbase::Bot::").public_send(:attribute_names)
      end

    end
  end
end
