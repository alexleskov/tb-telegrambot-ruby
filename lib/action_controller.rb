require './models/user'
require './lib/message_sender'
require './lib/message_responder'
require "encrypted_strings"

module Teachbase
  module Bot
    class ActionController
      VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      VALID_PASSWORD_REGEXP = /[\w|._#*^!+=@-]{6,40}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :user, :message_responder, :tb_bot_client, :tg_info

      def initialize(message_responder)
        @user = message_responder.user
        @message_responder = message_responder
        @tb_bot_client = message_responder.tb_bot_client
        @tg_info = message_responder.tg_info
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @logger = AppConfigurator.new.get_logger
        # @logger.debug "mes_res: '#{message_responder}"
      end

      def answer(text)
        MessageSender.new(bot: message_responder.bot, chat: message_responder.message.chat, text: text).send
      end

      def take_data
        message_responder.bot.listen do |message|
          @logger.debug "taking data: @#{message.from.username}: #{message.text}"
          break message.text
        end
      end

      def match_data
        on %r{^/start} do
          answer_with_greeting_message
          strating_menu
        end

        on %r{^/close} do
          answer_with_farewell_message
        end

        on %r{^/hide_menu} do
          hide_menu
        end
      end

      def signin
        answer "#{Emoji.find_by_alias('rocket').raw}*#{I18n.t('signin')} #{I18n.t('in_teachbase')}*"
        @logger.debug "user: #{user.first_name}, #{user.last_name}"

        if user.tb_api.nil?
          loop do
            answer I18n.t('add_user_email').to_s
            user.email = request_data(:email)
            answer I18n.t('add_user_password').to_s
            user.password = request_data(:password)
            break if [user.email, user.password].any?(nil) || [user.email, user.password].all?(String)
          end
        end

        raise if [user.email, user.password].any?(nil)

        user.password.encrypt!(:symmetric, password: @encrypt_key)
        user.api_auth(:mobile_v2, user_email: user.email, password: user.password.decrypt)
        @logger.debug "user2: #{user.first_name}, #{user.last_name}, #{user.tb_api}, token: #{user.tb_api.token.value}"
        profile = load_profile
        user.first_name = profile["name"]
        user.last_name = profile["last_name"]
        user.external_id = profile["id"]
        user.phone = profile["phone"]
        answer I18n.t('auth_success')
        user.save
        answer "#{Emoji.find_by_alias('heart').raw}*#{I18n.t('greetings')}* *#{I18n.t('in_teachbase')}!*
                \n[#{profile['name']} #{profile['last_name']}](#{profile['avatar_url']})"
        learning_profile_state

        test_inline_menu
      rescue RuntimeError => e
        answer "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"

        # retry
      end

      private

      def request_data(validate_type)
        data = take_data
        return if data =~ ABORT_ACTION_COMMAND || tb_bot_client.commands.values.include?(data)

        value = data if validation(validate_type, data)
      end

      def load_profile
        retries ||= 0
        retries_off = 3
        user.load_profile
      rescue RuntimeError => e
        answer "#{I18n.t('error')} #{e}\n#{I18n.t('retry')}: ##{retries}.. (#{retries_off})"
        retry if (retries += 1) < 3
      end

      def learning_profile_state
        profile = load_profile
        answer "#{I18n.t('profile_state')}
        \n#{Emoji.find_by_alias('green_book').raw}#{I18n.t('courses')}: #{I18n.t('active_courses')}: #{profile['active_courses_count']} / #{I18n.t('archived_courses')}: #{profile['archived_courses_count']}
        \n#{Emoji.find_by_alias('school').raw}#{I18n.t('average_score_percent')}: #{profile['average_score_percent']}%
        \n#{Emoji.find_by_alias('hourglass').raw}#{I18n.t('total_time_spent')}: #{profile['total_time_spent'] / 3600} #{I18n.t('hour')}"
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

      def answer_with_greeting_message
        first_name = user.first_name.nil? ? tg_info[:first_name] : user.first_name
        last_name = user.first_name.nil? ? tg_info[:last_name] : user.last_name
        answer "#{I18n.t('greeting_message')} #{first_name} #{last_name}!"
      end

      def answer_with_farewell_message
        first_name = user.first_name.nil? ? tg_info[:first_name] : user.first_name
        last_name = user.first_name.nil? ? tg_info[:last_name] : user.last_name
        answer "#{I18n.t('farewell_message')} #{first_name} #{last_name}!"
      end

      def strating_menu
        create_menu([tb_bot_client.commands[:signin], tb_bot_client.commands[:settings]], :menu, I18n.t('start_menu_message'))
      end

      def test_inline_menu
        buttons = [[text: "go.teachbase.ru", url: "http://go.teachbase.ru"], [text: "teachbase.ru", url: "http://teachbase.ru"]]
        MessageSender.new(bot: message_responder.bot,
                          chat: message_responder.message.chat,
                          text: "Test inline menu",
                          menu_inline: { buttons: buttons, slices: 2 }).send
      end

      def hide_menu
        MessageSender.new(bot: message_responder.bot, chat: message_responder.message.chat, text: I18n.t('farewell_message'), hide_kb: true).send
      end

      def create_menu(buttons, type, text, slices_count = nil)
        raise "'buttons' must be Array" unless buttons.is_a?(Array)
        raise "No such menu type: #{type}" unless %i[menu menu_inline].include?(type)

        menu_params = { bot: message_responder.bot,
                        chat: message_responder.message.chat,
                        text: text, type => { buttons: buttons, slices: slices_count } }
        MessageSender.new(menu_params).send
      end

      def on(command, &block)
        command =~ message_responder.message.text
        if $~
          case block.arity
          when 0
            yield
          when 1
            yield $1
          when 2
            yield $1, $2
          end
        end
      end
    end
  end
end
