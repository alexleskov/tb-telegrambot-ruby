require './lib/message_sender'
require './lib/message_responder'
require './models/api_token'
require './models/answer'
require './models/menu'
require './models/course_session'
require './models/section'
require './models/material'
require './lib/data_loader'
require 'encrypted_strings'

module Teachbase
  module Bot
    class Controller
      VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      VALID_PASSWORD_REGEXP = /[\w|._#*^!+=@-]{6,40}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :user, :message_responder, :answer, :menu, :destination, :commands, :data_loader

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
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        @logger = AppConfigurator.new.get_logger
        @apitoken = data_loader.apitoken
        # @logger.debug "mes_res: '#{message_responder}"
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def signin
        data_loader.auth_checker
        answer.send "*#{I18n.t('greetings')}* *#{I18n.t('in_teachbase')}!*"
        show_profile_state
        menu.after_auth
        call_data_from_profile

        #menu.testing
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def settings
        data_loader.auth_checker
        answer.send "#{Emoji.find_by_alias('wrench').raw}*#{I18n.t('settings')} #{I18n.t('for_profile')}*
        \n#{I18n.t('stage_empty')}"
      end

      def show_profile_state
        data_loader.call_profile if @profile.nil?

        @profile = data_loader.profile
        answer.send "#{Emoji.find_by_alias('mortar_board').raw}*#{I18n.t('profile_state')}*
        \n  #{Emoji.find_by_alias('green_book').raw}#{I18n.t('courses')}: #{I18n.t('active_courses')}: #{@profile['active_courses_count']} / #{I18n.t('archived_courses')}: #{@profile['archived_courses_count']}
        \n  #{Emoji.find_by_alias('school').raw}#{I18n.t('average_score_percent')}: #{@profile['average_score_percent']}%
        \n  #{Emoji.find_by_alias('hourglass').raw}#{I18n.t('total_time_spent')}: #{@profile['total_time_spent'] / 3600} #{I18n.t('hour')}
        \n  [#{@profile['name']} #{@profile['last_name']}](#{@profile['avatar_url']})"
      end

      def course_list_l1
        menu.course_sessions_choice
      end

      def course_sessions_list(param)
        course_sessions = Teachbase::Bot::CourseSession.where(user_id: user.id, complete_status: param.to_s)
        data_loader.call_course_sessions_list(param) if course_sessions.empty?
        
        course_sessions = Teachbase::Bot::CourseSession.where(user_id: user.id, complete_status: param.to_s)
        case param
        when :active
          answer.send "#{Emoji.find_by_alias('green_book').raw}*#{I18n.t('active_courses').capitalize!}*"
        when :archived
          answer.send "#{Emoji.find_by_alias('closed_book').raw}*#{I18n.t('archived_courses').capitalize!}*"
        end

        course_sessions.each do |course_session|
          buttons = [[text: "#{I18n.t('open')}" , callback_data: "cs_id:#{course_session.id}"], [text: "#{I18n.t('course_results')}" , callback_data: "cs_info_id:#{course_session.id}"]]
          menu.create(buttons, :menu_inline, "[#{I18n.t('course')}](#{course_session.icon_url}): #{course_session.course_name}", 2)
        end

      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
        auth_checker  
      end

      def course_session_show_info(course_session_id)
        course_session = Teachbase::Bot::CourseSession.where(user_id: user.id, id: course_session_id).first

        deadline = course_session.deadline.nil? ? "\u221e" : Time.at(course_session.deadline.to_i).utc

        answer.send "* #{I18n.t('course')}: #{course_session.course_name}*
        \n  #{Emoji.find_by_alias('runner').raw}#{I18n.t('started_at')}: #{course_session.started_at}
        \n  #{Emoji.find_by_alias('alarm_clock').raw}#{I18n.t('deadline')}: #{deadline} 
        \n  #{Emoji.find_by_alias('chart_with_upwards_trend').raw}#{I18n.t('progress')}: #{course_session.progress}%
        \n  #{Emoji.find_by_alias('book').raw}#{I18n.t('complete_status')}: #{I18n.t("complete_status_#{course_session.complete_status}")}
        \n  #{Emoji.find_by_alias('trophy').raw}#{I18n.t('success')}: #{I18n.t("success_#{course_session.success}")}
        "
      end

      def course_session_open(course_session_id)
        data_loader.call_course_session_section(course_session_id)
        sections = Teachbase::Bot::Section.order(position: :asc).joins('LEFT JOIN course_sessions ON sections.course_sessions_id = course_sessions.id')
        .where('course_sessions.id = :id', id: course_session_id)
        course_session = Teachbase::Bot::CourseSession.all.select(:course_name).find_by(id: course_session_id)
        mess = []
        sec_index = 1
        sections.each do |section|
          string = "\n*#{I18n.t('section')} #{sec_index}:* #{section.part_name}"
          mess << string
          sec_index += 1
        end

        answer_message = mess.join("\n")

        answer.send "*#{Emoji.find_by_alias('book').raw}#{I18n.t('course')}: #{course_session.course_name}*\n#{answer_message}"
        buttons = [[text: "#{I18n.t('open')} #{I18n.t('in')} #{I18n.t('section')}" , callback_data: "cs_sec_id:#{course_session.id}"]]
        menu.create(buttons, :menu_inline, "#{I18n.t('start_menu_message')}", 1)
      end

      def section_show_materials(position, course_session_id)
        materials = Teachbase::Bot::Materials.order(id: :asc).joins('LEFT JOIN sections ON materials.sections_id = sections.id')
        .where('course_sessions.id = :id', id: course_session_id)
        section = Teachbase::Bot::Section.find_by(course_sessions_id: course_session_id, position: position)
      end

      def authorization
        loop do
          answer.send I18n.t('add_user_email')
          user.email = request_data(:email)
          answer.send I18n.t('add_user_password')
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
        raise "Can't load API Token" unless @apitoken

        user.password.encrypt!(:symmetric, password: @encrypt_key)
        user.auth_at = Time.now.utc
        user.save
        answer.send I18n.t('auth_success')
        @apitoken = data_loader.apitoken
        menu.hide

      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
        retry
      end

      protected

      def call_data_from_profile
        data_loader.call_course_sessions_list(:active)
        data_loader.call_course_sessions_list(:archived)
      end

      def take_data
        message_responder.bot.listen do |message|
          @logger.debug "taking data: @#{message.from.username}: #{message.text}"
          break message.text
        end
      end

      def request_data(validate_type)
        data = take_data
        return value = nil if data =~ ABORT_ACTION_COMMAND || commands.command_by?(:value, data)

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

      def on(command, param, &block)
        raise "No such param '#{param}'. Must be :text or :data" unless [:text,:data].include?(param)
        @message_value = param == :text ? message_responder.message.text : message_responder.message.data

        command =~ @message_value
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
