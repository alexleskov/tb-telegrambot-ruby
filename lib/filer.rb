# frozen_string_literal: true

module Teachbase
  module Bot
    class Filer
      URL_PATH = "https://api.telegram.org/file/bot"
      TMP_FOLDER = "tmp"

      include Formatter

      def initialize(bot)
        @bot = bot
      end

      def file_path(file_id)
        @bot.api.get_file(file_id: file_id)["result"]["file_path"]
      end

      def download_url(file_id)
        "#{URL_PATH}#{load_bot_token}/#{file_path(file_id)}"
      end

      def upload(file_id)
        download = open(download_url(file_id))
        return unless download.status.first == "200"

        local_file = IO.copy_stream(download, build_local_path(download))
        unless local_file == download.meta["content-length"].to_i
          raise "Failed upload on local storage. File: #{download.base_uri}"
        end

        File.open(build_local_path(download), 'rb')
      end

      private

      def build_local_path(download)
        "/#{TMP_FOLDER}/#{Time.now.getutc.to_i}_#{chomp_file_name(download.base_uri)}"
      end

      def load_bot_token
        $app_config.load_token
      end
    end
  end
end
