# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class CommandController < Teachbase::Bot::Controller
      def initialize(params)
        super(params, :chat)
      end

      def find_command
        @c_data = command_list.find_by(:value, message.text).key
      end

      alias source find_command
    end
  end
end
