# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class CommandController < Teachbase::Bot::Controller
      def initialize(params)
        super(params, :chat)
      end

      def push_command
        command = command_list.find_by(:value, message.text).key
        raise "Can't respond on such command: #{command}." unless respond_to? command

        public_send(command)
      end
    end
  end
end
