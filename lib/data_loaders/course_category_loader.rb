# frozen_string_literal: true

module Teachbase
  module Bot
    class CourseCategoryLoader < Teachbase::Bot::DataLoaderController
      CUSTOM_ATTRS = {}.freeze

      attr_reader :cs_loader

      def initialize(cs_loader)
        raise "'#{cs_loader}' is not UserLoader" unless cs_loader.is_a?(Teachbase::Bot::CourseSessionLoader)

        @cs_loader = cs_loader
        @appshell = cs_loader.appshell
      end

      def model_class
        Teachbase::Bot::CourseCategory
      end

      def me
        cs_loader.info
        return if cs_loader.lms_info["course_types"].empty?

        cs_loader.lms_info["course_types"].each do |course_type_lms|
          model_class.find_or_create_by!(course_session_id: cs_loader.cs_id,
                                         category_id: init_category_loader(lms_info: course_type_lms).me.id)
        end
      end

      private

      def init_category_loader(params)
        Teachbase::Bot::CategoryLoader.new(appshell, params)
      end
    end
  end
end
