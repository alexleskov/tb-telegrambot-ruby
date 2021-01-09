# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class FileController < Teachbase::Bot::Controller
      attr_reader :file_id, :file_size, :file_type

      def initialize(params)
        super(params, :chat)
        @file_id = source.file_id
        @file_size = source.file_size
        @file_type = type
      end

      def save_message(mode)
        return unless source

        @message_params[:message_type] = "file"
        @message_params[:data] = { file_id: file_id, file_size: file_size, file_type: file_type }
        @message_params[:file_id] = file_id
        @message_params[:file_size] = file_size
        @message_params[:file_type] = type
        super(mode)
      end
    end
  end
end
