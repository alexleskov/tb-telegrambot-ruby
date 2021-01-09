# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class FileController < Teachbase::Bot::Controller

      def initialize(params)
        super(params, :chat)
      end

      def save_message(mode)
        return unless source

        @message_params[:message_type] = "file"
        @message_params[:file_id] = @message_params[:data] = source.file_id
        @message_params[:file_size] = source.file_size
        @message_params[:file_type] = type
        super(mode)
      end
    end
  end
end
