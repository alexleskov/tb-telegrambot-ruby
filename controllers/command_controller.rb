# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class CommandController < Teachbase::Bot::Controller
      def initialize(params)
        @type = "command"
        super(params, :chat)
      end

      def source
        context.message.text
      end

      def find_command
        @c_data = respond.command_list.find_by(:value, source).key
      end
    end
  end
end
