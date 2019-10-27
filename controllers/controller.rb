require './lib/message_sender'
require './lib/message_responder'
require './models/answer'
require './models/menu'
require './models/course_session'
require './models/section'
require './models/material'
require './lib/data_loader'


module Teachbase
  module Bot
    class Controller
      VALID_EMAIL_REGEXP = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
      VALID_PASSWORD_REGEXP = /[\w|._#*^!+=@-]{6,40}$/.freeze
      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :user, :message_responder, :answer, :menu, :destination, :data_loader

      def initialize(message_responder, dest = :chat)
        raise "No such destination '#{dest}' for send menu" unless [:chat,:from].include?(dest)

        msg = message_responder.message
        @destination = msg.public_send(dest) if msg.respond_to? dest
        raise "Can't find menu destination for message #{message_responder}" if destination.nil?

        @message_responder = message_responder
        @answer = Teachbase::Bot::Answer.new(message_responder, dest)
        @menu = Teachbase::Bot::Menu.new(message_responder, dest)
        @data_loader = Teachbase::Bot::DataLoader.new(self)
        @logger = AppConfigurator.new.get_logger
        @user = data_loader.user
        # @logger.debug "mes_res: '#{message_responder}"
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def signin
        answer.send "#{Emoji.find_by_alias('rocket').raw}<b>#{I18n.t('enter')} #{I18n.t('in_teachbase')}</b>"
        data_loader.auth_checker
        answer.send I18n.t('auth_success')
        answer.send "<b>#{I18n.t('greetings')} #{I18n.t('in_teachbase')}!</b>"
        menu.hide
        show_profile_state
        menu.after_auth
        data_loader.call_data_course_sessions
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def settings
        data_loader.auth_checker
        answer.send "<b>#{Emoji.find_by_alias('wrench').raw}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
        \n#{I18n.t('stage_empty')}"
      end

      def show_profile_state
        data_loader.call_profile if @profile.nil?

        @profile = data_loader.profile
        answer.send "<b>#{Emoji.find_by_alias('mortar_board').raw}#{I18n.t('profile_state')}</b>
        \n  <a href='#{@profile['avatar_url']}'>#{@profile['name']} #{@profile['last_name']}</a>
        \n  #{Emoji.find_by_alias('green_book').raw}#{I18n.t('courses')}: #{I18n.t('active_courses')}: #{@profile['active_courses_count']} / #{I18n.t('archived_courses')}: #{@profile['archived_courses_count']}
        \n  #{Emoji.find_by_alias('school').raw}#{I18n.t('average_score_percent')}: #{@profile['average_score_percent']}%
        \n  #{Emoji.find_by_alias('hourglass').raw}#{I18n.t('total_time_spent')}: #{@profile['total_time_spent'] / 3600} #{I18n.t('hour')}"
      end

      def course_list_l1
        menu.course_sessions_choice
      end

      def update_profile_data
        answer.send "<b>#{Emoji.find_by_alias('arrows_counterclockwise').raw}#{I18n.t('updating_profile')}</b>"
        course_sessions = data_loader.call_data_course_sessions
        @profile = data_loader.call_profile
        raise "Profile update failed" unless course_sessions || @profile
        answer.send "<i>#{Emoji.find_by_alias('+1').raw}#{I18n.t('updating_success')}</i>"
      end

      def course_sessions_list(param)
        course_sessions = Teachbase::Bot::CourseSession.where(user_id: user.id, complete_status: param.to_s)
        data_loader.call_course_sessions_list(param) if course_sessions.empty?
        
        course_sessions = Teachbase::Bot::CourseSession.where(user_id: user.id, complete_status: param.to_s)
        case param
        when :active
          answer.send "#{Emoji.find_by_alias('green_book').raw}<b>#{I18n.t('active_courses').capitalize!}</b>"
        when :archived
          answer.send "#{Emoji.find_by_alias('closed_book').raw}<b>#{I18n.t('archived_courses').capitalize!}</b>"
        end

        if course_sessions.empty?
          answer.send "#{Emoji.find_by_alias('book').raw} #{I18n.t('course')}: <b>#{course_session.name}</b>
          \n#{Emoji.find_by_alias('soon').raw} <i>#{I18n.t('empty')}</i>"
        else
          course_sessions.each do |course_session|
            buttons = [[text: "#{I18n.t('open')}", callback_data: "cs_id:#{course_session.id}"], [text: "#{I18n.t('course_results')}", callback_data: "cs_info_id:#{course_session.id}"]]
            menu.create(buttons, :menu_inline, "#{Emoji.find_by_alias('book').raw} <a href='#{course_session.icon_url}'>#{I18n.t('course')}</a>: <b>#{course_session.name}</b>", 2)
          end
        end
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')}" 
      end

      def course_session_show_info(cs_id)
        course_session = Teachbase::Bot::CourseSession.order(name: :asc).find_by(user_id: user.id, id: cs_id)

        deadline = course_session.deadline.nil? ? "\u221e" : Time.at(course_session.deadline).utc.strftime("%d.%m.%Y %H:%M")
        started_at = course_session.started_at.nil? ? "-" : Time.at(course_session.started_at).utc.strftime("%d.%m.%Y %H:%M")

        answer.send "#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session.name} - #{Emoji.find_by_alias('information_source').raw} #{I18n.t('information')}</b>
        \n  #{Emoji.find_by_alias('runner').raw}#{I18n.t('started_at')}: #{started_at}
        \n  #{Emoji.find_by_alias('alarm_clock').raw}#{I18n.t('deadline')}: #{deadline} 
        \n  #{Emoji.find_by_alias('chart_with_upwards_trend').raw}#{I18n.t('progress')}: #{course_session.progress}%
        \n  #{Emoji.find_by_alias('star2').raw}#{I18n.t('complete_status')}: #{I18n.t("complete_status_#{course_session.complete_status}")}
        \n  #{Emoji.find_by_alias('trophy').raw}#{I18n.t('success')}: #{I18n.t("success_#{course_session.success}")}"
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')}" 
      end

      def sections_show(cs_id)
        data_loader.call_course_session_section(cs_id)
        sections = Teachbase::Bot::Section.order(position: :asc).where(course_session_id: cs_id, user_id: user.id)
        course_session_name = Teachbase::Bot::CourseSession.select(:name).find_by(id: cs_id, user_id: user.id).name
        if sections.empty?
          answer.send "\n-----------------------------
                       \n#{Emoji.find_by_alias('book').raw} #{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_down').raw} <b>#{I18n.t('course_sections')}</b>
                       \n#{Emoji.find_by_alias('soon').raw} <i>#{I18n.t('empty')}</i>" 
        else
          mess = []
          sections.each do |section|
            if section.is_publish && section.is_available
              string = "\n#{Emoji.find_by_alias('arrow_forward').raw} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n#{I18n.t('open')}: /sec#{section.position}_cs#{cs_id}"
            elsif section.is_publish && !section.is_available && !section.opened_at
              string = "\n#{Emoji.find_by_alias('no_entry_sign').raw} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n#{I18n.t('section_unable')}."
            elsif section.is_publish && !section.is_available && section.opened_at
              string = "\n#{Emoji.find_by_alias('no_entry_sign').raw} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n#{I18n.t('section_delayed')} #{Time.at(section.opened_at).utc.strftime("%d.%m.%Y %H:%M")}."
            elsif !section.is_publish
              string = "\n#{Emoji.find_by_alias('x').raw} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n#{I18n.t('section_unpublish')}."
            end
            mess << string
          end
          answer_message = mess.join("\n")
          answer.send "\n-----------------------------
          \n#{Emoji.find_by_alias('book').raw} #{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_down').raw} <b>#{I18n.t('course_sections')}</b>\n#{answer_message}"
        end
      rescue => e
        answer.send "#{I18n.t('error')}"
      end

      def section_show_materials(section_position, cs_id)
        materials = Teachbase::Bot::Material
                    .order(id: :asc)
                    .joins(:section).where("sections.course_session_id = :cs_id and sections.position = :sec_position and sections.user_id = :user_id",
                           cs_id: cs_id, sec_position: section_position, user_id: user.id)
        section_name = Teachbase::Bot::Section.select(:name).find_by(course_session_id: cs_id, position: section_position, user_id: user.id).name
        course_session_name = Teachbase::Bot::CourseSession.select(:name).find_by(id: cs_id, user_id: user.id).name
        if materials.empty?
          answer.send "\n#{Emoji.find_by_alias('book').raw} #{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_forward').raw} <b>#{I18n.t('section')}: #{section_name}</b>
          \n#{Emoji.find_by_alias('soon').raw} <i>#{I18n.t('empty')}</i>"
        else
          mess = []
          materials.each do |material|
            string = "\n#{Emoji.find_by_alias('page_facing_up').raw}<b>#{I18n.t('material')}:</b> #{material.name}"
            mess << string
          end
          answer_message = mess.join("\n")
          answer.send "\n#{Emoji.find_by_alias('book').raw} #{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_forward').raw} <b>#{I18n.t('section')}: #{section_name}</b>\n#{answer_message}"
        end
      rescue => e
        answer.send "#{I18n.t('error')}" 
      end

      def authorization
        loop do
          answer.send I18n.t('add_user_email')
          user.email = request_data(:email)
          answer.send I18n.t('add_user_password')
          user.password = request_data(:password)
          break if [user.email, user.password].any?(nil) || [user.email, user.password].all?(String)
        end
      end

      protected

      def take_data
        message_responder.bot.listen do |message|
          @logger.debug "taking data: @#{message.from.username}: #{message.text}"
          break message.text
        end
      end

      def request_data(validate_type)
        data = take_data
        return value = nil if data =~ ABORT_ACTION_COMMAND || message_responder.commands.command_by?(:value, data)

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
