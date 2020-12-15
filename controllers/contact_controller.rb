# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class ContactController < Teachbase::Bot::Controller
      attr_reader :phone_number, :first_name, :last_name, :tg_user, :vcard

      def initialize(params)
        super(params, :chat)
        @phone_number = message.contact.phone_number
        @first_name = message.contact.first_name
        @last_name = message.contact.last_name
        @tg_user = message.contact.user_id
        @vcard = message.contact.vcard
      end

      def source
        self
      end

    end
  end
end
