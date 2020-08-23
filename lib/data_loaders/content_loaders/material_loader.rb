# frozen_string_literal: true

module Teachbase
  module Bot
    class MaterialLoader < Teachbase::Bot::ContentLoaderController
      VIDEO_FILE_TYPE = "mp4"
      CUSTOM_ATTRS = {}.freeze
      METHOD_CNAME = :materials

      def model_class
        Teachbase::Bot::Material
      end

      def track(time_spent)
        raise unless db_entity

        update_data(lms_upload(data: :track, time_spent: time_spent), :no_create)
      end

      private

      def lms_upload(options)
        @lms_info = call_data do
          case options[:data].to_sym
          when :track
            appshell.authsession.track_material(cs_tb_id, tb_id, options[:time_spent])
          end
        end
      end

      def lms_load
        @lms_info = call_data { appshell.authsession.load_material(cs_tb_id, tb_id) }
        fetch_video_file
        lms_info
      end

      def fetch_video_file
        return unless lms_info["type"] == "video" && lms_info["source"].is_a?(Hash)

        lms_info["source"] = lms_info["source"][VIDEO_FILE_TYPE]
      end
    end
  end
end
