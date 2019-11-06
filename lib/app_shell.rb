require './models/course_session'
require './models/section'
require './models/material'
require './models/auth_session'
require './lib/data_loader'


module Teachbase
  module Bot
    class AppShell
      VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      VALID_PASSWORD_REGEXP = /[\w|._#*^!+=@-]{6,40}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :controller, :user

      def initialize(controller)
        @controller = controller
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        @user = data_loader.user
        @logger = AppConfigurator.new.get_logger
        # @logger.debug "mes_res: '#{respond}"
      rescue RuntimeError => e
        controller.answer.send "#{I18n.t('error')} #{e}"
      end

      def authorization
        loop do
          controller.answer.send I18n.t('add_user_email')
          user.email = request_data(:email)
          controller.answer.send I18n.t('add_user_password')
          user.password = request_data(:password)
          break if [user.email, user.password].any?(nil) || [user.email, user.password].all?(String)
        end
      end

      protected

      def take_data
        respond.bot.listen do |message|
          @logger.debug "taking data: @#{controller.respond.message.from.username}: #{controller.respond.message.text}"
          break controller.respond.message.text
        end
      end

      def request_data(validate_type)
        data = take_data
        return value = nil if data =~ ABORT_ACTION_COMMAND || controller.respond.commands.command_by?(:value, data)

        value = data if validation(validate_type, data)
      end

      def validation(type, value)
        return unless value

        case type
        when :email
          value =~ VALID_EMAIL_REGEXP
        when :password
          value =~ VALID_PASSWORD_REGEXP
        when :string
          value.is_a?(String)
        end
      end

    end
  end
end
