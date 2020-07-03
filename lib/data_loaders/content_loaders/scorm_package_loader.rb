# frozen_string_literal: true

module Teachbase
  module Bot
    class ScormPackageLoader < Teachbase::Bot::ContentLoaderController
      CUSTOM_ATTRS = {}.freeze
      METHOD_CNAME = :scorm_packages

      def model_class
        Teachbase::Bot::ScormPackage
      end

      private

      def lms_load
        @lms_info = call_data { appshell.authsession.load_scorm_package(cs_tb_id, tb_id) }
      end
    end
  end
end
