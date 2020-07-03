# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class FileController < Teachbase::Bot::Controller
      attr_reader :type

      def initialize(params)
        super(params, :chat)
      end

      def save_message(mode)
        return unless file

        @message_params = { file_id: file.file_id, file_size: file.file_size, file_type: type, message_type: "file" }
        super(mode)
      end
    end
  end
end
