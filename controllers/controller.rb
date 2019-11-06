require './lib/message_sender'
require './models/answer'
require './models/menu'
require './models/course_session'
require './models/section'
require './models/material'
require './lib/app_shell'


module Teachbase
  module Bot
    class Controller

      attr_reader :user, :respond, :answer, :menu, :data_loader

      def initialize(respond, dest = :chat)
        raise "No such destination '#{dest}' for send menu or message" unless [:chat,:from].include?(dest)
        @respond = respond
        @appshell =  Teachbase::Bot::AppShell.new(self)

        @user = data_loader.user
        @answer = Teachbase::Bot::Answer.new(respond, dest)
        @menu = Teachbase::Bot::Menu.new(respond, dest)
        @logger = AppConfigurator.new.get_logger
        # @logger.debug "mes_res: '#{respond}"
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def signin
        answer.send "#{Emoji.find_by_alias('rocket').raw}<b>#{I18n.t('enter')} #{I18n.t('in_teachbase')}</b>"
        data_loader.auth_checker
        answer.send "<b>#{I18n.t('greetings')} #{I18n.t('in_teachbase')}!</b>"
        menu.hide
        show_profile_state
        menu.after_auth
        data_loader.call_data_course_sessions
      rescue RuntimeError => e
        answer.send "#{I18n.t('error')} #{e}"
      end

      def sign_out
        answer.send "#{Emoji.find_by_alias('door').raw}<b>#{I18n.t('sign_out')}</b>"
        token = data_loader.apitoken
        token.update!(active: false)
        menu.hide
        menu.starting
      end

      def settings
        data_loader.auth_checker
        answer.send "<b>#{Emoji.find_by_alias('wrench').raw}#{I18n.t('settings')} #{I18n.t('for_profile')}</b>
        \n#{I18n.t('stage_empty')}"
      end

      def show_profile_state
        data_loader.call_profile
        answer.send "<b>#{Emoji.find_by_alias('mortar_board').raw}#{I18n.t('profile_state')}</b>
        \n  <a href='#{user.avatar_url}'>#{user.first_name} #{user.last_name}</a>
        \n  #{Emoji.find_by_alias('green_book').raw}#{I18n.t('courses')}: #{I18n.t('active_courses')}: #{user.active_courses_count} / #{I18n.t('archived_courses')}: #{user.archived_courses_count}
        \n  #{Emoji.find_by_alias('school').raw}#{I18n.t('average_score_percent')}: #{user.average_score_percent}%
        \n  #{Emoji.find_by_alias('hourglass').raw}#{I18n.t('total_time_spent')}: #{user.total_time_spent / 3600} #{I18n.t('hour')}"
      end

      def course_list_l1
        menu.course_sessions_choice
      end

      def update_course_sessions
        answer.send "<b>#{Emoji.find_by_alias('arrows_counterclockwise').raw}#{I18n.t('updating_data')}</b>"
        course_sessions = data_loader.call_data_course_sessions
        raise "Course sessions update failed" unless course_sessions
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
          answer.send "\n
                       \n#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_down').raw} #{I18n.t('course_sections')}</b>
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
          answer.send "\n
          \n#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_down').raw} #{I18n.t('course_sections')}</b>\n#{answer_message}"
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
          answer.send "\n#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_forward').raw} #{I18n.t('section')}: #{section_name}</b>
          \n#{Emoji.find_by_alias('soon').raw} <i>#{I18n.t('empty')}</i>"
        else
          mess = []
          materials.each do |material|
            string = "\n#{Emoji.find_by_alias('page_facing_up').raw}<b>#{I18n.t('material')}:</b> #{material.name}"
            mess << string
          end
          answer_message = mess.join("\n")
          answer.send "\n#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_forward').raw} #{I18n.t('section')}: #{section_name}</b>\n#{answer_message}"
        end
      rescue => e
        answer.send "#{I18n.t('error')}" 
      end

      protected

      def on(command, param, &block)
        raise "No such param '#{param}'. Must be :text or :data" unless [:text,:data].include?(param)
        @message_value = param == :text ? respond.message.text : respond.message.data

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
