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
        return unless source

        @message_params[:file_id] = source.file_id
        @message_params[:file_size] = source.file_size
        @message_params[:file_type] = type
        super(mode)
      end

      def message_type
        "file"
      end
    end
  end
end
