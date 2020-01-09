require './lib/message_sender'
require './lib/answers/answer'
require './lib/answers/answer_menu'
require './lib/answers/answer_text'
#require './models/course_session'
#require './models/section'
#require './models/material'
require './lib/app_shell'
require './lib/scenarios.rb'


module Teachbase
  module Bot
    class Controller
      MSG_TYPES = [:text, :data].freeze

      attr_reader :respond, :answer, :menu, :appshell

      def initialize(params, dest)
        @respond = params[:respond]
        raise unless respond
        @answer = Teachbase::Bot::AnswerText.new(respond, dest)
        @menu = Teachbase::Bot::AnswerMenu.new(respond, dest)
        @logger = AppConfigurator.new.get_logger
        @appshell = Teachbase::Bot::AppShell.new(self)
      rescue RuntimeError => e
        @logger.debug "Initialization Controller error: #{e}"
        answer.send_out "#{I18n.t('error')}"
      end

=begin  
      def course_sessions_list(param)
        course_sessions = Teachbase::Bot::CourseSession.where(user_id: user.id, complete_status: param.to_s)
        data_loader.call_course_sessions_list(param) if course_sessions.empty?
        
        course_sessions = Teachbase::Bot::CourseSession.where(user_id: user.id, complete_status: param.to_s)
        case param
        when :active
          answer.send_out "#{Emoji.find_by_alias('green_book').raw}<b>#{I18n.t('active_courses').capitalize!}</b>"
        when :archived
          answer.send_out "#{Emoji.find_by_alias('closed_book').raw}<b>#{I18n.t('archived_courses').capitalize!}</b>"
        end

        if course_sessions.empty?
          answer.send_out "#{Emoji.find_by_alias('book').raw} #{I18n.t('course')}: <b>#{course_session.name}</b>
          \n#{Emoji.find_by_alias('soon').raw} <i>#{I18n.t('empty')}</i>"
        else
          course_sessions.each do |course_session|
            buttons = [[text: "#{I18n.t('open')}", callback_data: "cs_id:#{course_session.id}"], [text: "#{I18n.t('course_results')}", callback_data: "cs_info_id:#{course_session.id}"]]
            menu.create(buttons, :menu_inline, "#{Emoji.find_by_alias('book').raw} <a href='#{course_session.icon_url}'>#{I18n.t('course')}</a>: <b>#{course_session.name}</b>", 2)
          end
        end
      rescue RuntimeError => e
        answer.send_out "#{I18n.t('error')}" 
      end

      def course_session_show_info(cs_id)
        course_session = Teachbase::Bot::CourseSession.order(name: :asc).find_by(user_id: user.id, id: cs_id)

        deadline = course_session.deadline.nil? ? "\u221e" : Time.at(course_session.deadline).utc.strftime("%d.%m.%Y %H:%M")
        started_at = course_session.started_at.nil? ? "-" : Time.at(course_session.started_at).utc.strftime("%d.%m.%Y %H:%M")

        answer.send_out "#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session.name} - #{Emoji.find_by_alias('information_source').raw} #{I18n.t('information')}</b>
        \n  #{Emoji.find_by_alias('runner').raw}#{I18n.t('started_at')}: #{started_at}
        \n  #{Emoji.find_by_alias('alarm_clock').raw}#{I18n.t('deadline')}: #{deadline} 
        \n  #{Emoji.find_by_alias('chart_with_upwards_trend').raw}#{I18n.t('progress')}: #{course_session.progress}%
        \n  #{Emoji.find_by_alias('star2').raw}#{I18n.t('complete_status')}: #{I18n.t("complete_status_#{course_session.complete_status}")}
        \n  #{Emoji.find_by_alias('trophy').raw}#{I18n.t('success')}: #{I18n.t("success_#{course_session.success}")}"
      rescue RuntimeError => e
        answer.send_out "#{I18n.t('error')}" 
      end

      def sections_show(cs_id)
        data_loader.call_course_session_section(cs_id)
        sections = Teachbase::Bot::Section.order(position: :asc).where(course_session_id: cs_id, user_id: user.id)
        course_session_name = Teachbase::Bot::CourseSession.select(:name).find_by(id: cs_id, user_id: user.id).name
        if sections.empty?
          answer.send_out "\n
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
          answer.send_out "\n
          \n#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_down').raw} #{I18n.t('course_sections')}</b>\n#{answer_message}"
        end
      rescue => e
        answer.send_out "#{I18n.t('error')}"
      end

      def section_show_materials(section_position, cs_id)
        materials = Teachbase::Bot::Material
                    .order(id: :asc)
                    .joins(:section).where("sections.course_session_id = :cs_id and sections.position = :sec_position and sections.user_id = :user_id",
                           cs_id: cs_id, sec_position: section_position, user_id: user.id)
        section_name = Teachbase::Bot::Section.select(:name).find_by(course_session_id: cs_id, position: section_position, user_id: user.id).name
        course_session_name = Teachbase::Bot::CourseSession.select(:name).find_by(id: cs_id, user_id: user.id).name
        if materials.empty?
          answer.send_out "\n#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_forward').raw} #{I18n.t('section')}: #{section_name}</b>
          \n#{Emoji.find_by_alias('soon').raw} <i>#{I18n.t('empty')}</i>"
        else
          mess = []
          materials.each do |material|
            string = "\n#{Emoji.find_by_alias('page_facing_up').raw}<b>#{I18n.t('material')}:</b> #{material.name}"
            mess << string
          end
          answer_message = mess.join("\n")
          answer.send_out "\n#{Emoji.find_by_alias('book').raw} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.find_by_alias('arrow_forward').raw} #{I18n.t('section')}: #{section_name}</b>\n#{answer_message}"
        end
      rescue => e
        answer.send_out "#{I18n.t('error')}" 
      end
=end
      protected

      def on(command, param, &block)
        raise "No such param '#{param}'. Must be a one of #{MSG_TYPES}" unless MSG_TYPES.include?(param)

        # TODO: Check @message_value
        @message_value = case param
                         when :text
                           respond.incoming_data.message.text
                         when :data
                           respond.incoming_data.message.data
                         else
                           raise "Can't find message for #{respond.incoming_data.message}, type: #{param}, available: #{MSG_TYPES}"
                         end
          
        #@message_value = param == :text ? respond.incoming_data.message.text : respond.incoming_data.message.data

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
