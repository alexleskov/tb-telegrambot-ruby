# frozen_string_literal: true

require './controllers/controller'

class Teachbase::Bot::CommandController < Teachbase::Bot::Controller
  def initialize(params)
    super(params, :chat)
  end

  def push_command
    command = respond.commands.find_by(:value, respond.msg_responder.message.text).key
    raise "Can't respond on such command: #{command}." unless respond_to? command

    public_send(command)
  end
end
