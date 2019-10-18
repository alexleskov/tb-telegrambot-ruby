require './lib/message_sender'
require './lib/message_responder'
require './models/api_token'
require './models/answer'
require './models/menu'
require 'encrypted_strings'

module Teachbase
  module Bot
    class Controller
      VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      VALID_PASSWORD_REGEXP = /[\w|._#*^!+=@-]{6,40}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :user, :message_responder, :answer, :menu, :destination, :commands

      def initialize(message_responder, dest = :chat)
        raise "No such destination '#{dest}' for send menu" unless [:chat,:from].include?(dest)

        msg = message_responder.message
        @destination = msg.public_send(dest) if msg.respond_to? dest
        raise "Can't find menu destination for message #{message_responder}" if destination.nil?

        @user = message_responder.user
        @message_responder = message_responder
        @commands = message_responder.commands
        @encrypt_key = AppConfigurator.new.get_encrypt_key
        @answer = Teachbase::Bot::Answer.new(message_responder, dest)
        @menu = Teachbase::Bot::Menu.new(message_responder, dest)
        @logger = AppConfigurator.new.get_logger
        @apitoken = Teachbase::Bot::ApiToken.find_by(user_id: user.id, active: true)
        # @logger.debug "mes_res: '#{message_responder}"
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def signin
        authorization
        return if !@apitoken.active?
        call_profile
        show_profile_state
        menu.testing
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def authorization
        answer.send "#{Emoji.find_by_alias('rocket').raw}*#{I18n.t('signin')} #{I18n.t('in_teachbase')}*"
        if @apitoken.nil? || !@apitoken.active?
          loop do
            answer.send I18n.t('add_user_email').to_s
            user.email = request_data(:email)
            answer.send I18n.t('add_user_password').to_s
            user.password = request_data(:password)
            break if [user.email, user.password].any?(nil) || [user.email, user.password].all?(String)
          end
          
          user.api_auth(:mobile_v2, user_email: user.email, password: user.password)

          raise "Can't authorize user id: #{user.id}. Token value: #{user.tb_api.token.value}" unless user.tb_api.token.value

          @apitoken = Teachbase::Bot::ApiToken.create!(user_id: user.id,
                                                       version: user.tb_api.token.version,
                                                       grant_type: user.tb_api.token.grant_type,
                                                       expired_at: user.tb_api.token.expired_at,
                                                       value: user.tb_api.token.value,
                                                       active: true)
        elsif @apitoken.active?
          raise "API Token value empty" if @apitoken.value.empty?
          user.api_auth(:mobile_v2, access_token: @apitoken.value)
        else
          raise "Can't load API Token"
        end
        user.password.encrypt!(:symmetric, password: @encrypt_key)
        user.auth_at = Time.now.utc
        user.save
        answer.send I18n.t('auth_success')

      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{I18n.t('auth_failed')} #{I18n.t('try_again')}"
        retry
      end

      def call_profile
        retries ||= 1
        retries_off = 3
        @profile = user.load_profile

        raise "Profile is not loaded" if @profile.nil?
        user.first_name = @profile["name"]
        user.last_name = @profile["last_name"]
        user.external_id = @profile["id"]
        user.phone = @profile["phone"]
        user.save
        answer.send "#{Emoji.find_by_alias('heart').raw}*#{I18n.t('greetings')}* *#{I18n.t('in_teachbase')}!*
                \n[#{@profile['name']} #{@profile['last_name']}](#{@profile['avatar_url']})"

      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}\n#{I18n.t('retry')}: ##{retries}.. (#{retries_off})"
        retry if (retries += 1) < 4
      end

      protected

      def show_profile_state
        raise if @profile.nil?
        answer.send "#{I18n.t('profile_state')}
        \n#{Emoji.find_by_alias('green_book').raw}#{I18n.t('courses')}: #{I18n.t('active_courses')}: #{@profile['active_courses_count']} / #{I18n.t('archived_courses')}: #{@profile['archived_courses_count']}
        \n#{Emoji.find_by_alias('school').raw}#{I18n.t('average_score_percent')}: #{@profile['average_score_percent']}%
        \n#{Emoji.find_by_alias('hourglass').raw}#{I18n.t('total_time_spent')}: #{@profile['total_time_spent'] / 3600} #{I18n.t('hour')}"
      end

      def take_data
        message_responder.bot.listen do |message|
          @logger.debug "taking data: @#{message.from.username}: #{message.text}"
          break message.text
        end
      end

      def request_data(validate_type)
        data = take_data
        return if data =~ ABORT_ACTION_COMMAND || commands.command_by?(:value,data)

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
