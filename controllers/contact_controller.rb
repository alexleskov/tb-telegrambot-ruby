# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class ContactController < Teachbase::Bot::Controller
      attr_reader :phone_number, :first_name, :last_name, :user_id, :vcard

      def initialize(params)
        @type = "contact"
        super(params, :chat)
        @phone_number = source.phone_number
        @first_name = source.first_name
        @last_name = source.last_name
        @user_id = source.user_id
        @vcard = source.vcard
      end

      def to_payload_hash
        { first_name: first_name, last_name: last_name, phone: phone_number.to_i.to_s }
      end

      def source
        context.message.contact
      end

      def save_message(mode)
        return unless source

        @message_params[:data] = { phone_number: phone_number, first_name: first_name, last_name: last_name, user_id: user_id }
        super(mode)
      end
    end
  end
end
