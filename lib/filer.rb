# frozen_string_literal: true

module Teachbase
  module Bot
    class Filer
      URL_PATH = "https://api.telegram.org/file/bot"
      TMP_FOLDER = "tmp"

      include Formatter

      attr_reader :bot, :tg_user

      def initialize(respond)
        @logger = AppConfigurator.new.load_logger
        @respond = respond
        @tg_user = respond.msg_responder.tg_user
        @bot = respond.msg_responder.bot
      end

      def file_path(file_id)
        bot.api.get_file(file_id: file_id)["result"]["file_path"]
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
        "/#{TMP_FOLDER}/#{tg_user.id}_#{download.base_uri.to_s.split('/')[-1]}"
      end

      def load_bot_token
        AppConfigurator.new.load_token
      end
    end
  end
end
