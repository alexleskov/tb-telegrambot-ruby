require './lib/message_sender'
require './lib/answers/answer'
require './lib/answers/answer_menu'
require './lib/answers/answer_text'
# require './models/section'
# require './models/material'
require './lib/app_shell'
require './lib/scenarios.rb'

module Teachbase
  module Bot
    class Controller
      MSG_TYPES = %i[text data].freeze

      attr_reader :respond, :answer, :menu, :appshell

      def initialize(params, dest)
        @respond = params[:respond]
        raise "Respond not found" unless respond

        @logger = AppConfigurator.new.get_logger
        @tg_user = respond.incoming_data.tg_user
        @message = respond.incoming_data.message
        @appshell = Teachbase::Bot::AppShell.new(self)
        @answer = Teachbase::Bot::AnswerText.new(appshell, dest)
        @menu = Teachbase::Bot::AnswerMenu.new(appshell, dest)
      rescue RuntimeError => e
        @logger.debug "Initialization Controller error: #{e}"
        answer.send_out I18n.t('error').to_s
      end

      #
      #       def section_show_materials(section_position, cs_id)
      #         materials = Teachbase::Bot::Material
      #                     .order(id: :asc)
      #                     .joins(:section).where("sections.course_session_id = :cs_id and sections.position = :sec_position and sections.user_id = :user_id",
      #                            cs_id: cs_id, sec_position: section_position, user_id: user.id)
      #         section_name = Teachbase::Bot::Section.select(:name).find_by(course_session_id: cs_id, position: section_position, user_id: user.id).name
      #         course_session_name = Teachbase::Bot::CourseSession.select(:name).find_by(id: cs_id, user_id: user.id).name
      #         if materials.empty?
      #           answer.send_out "\n#{Emoji.t(:book)} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.t(:arrow_forward)} #{I18n.t('section')}: #{section_name}</b>
      #           \n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
      #         else
      #           mess = []
      #           materials.each do |material|
      #             string = "\n#{Emoji.t(:page_facing_up)}<b>#{I18n.t('material')}:</b> #{material.name}"
      #             mess << string
      #           end
      #           answer_message = mess.join("\n")
      #           answer.send_out "\n#{Emoji.t(:book)} <b>#{I18n.t('course')}: #{course_session_name} - #{Emoji.t(:arrow_forward)} #{I18n.t('section')}: #{section_name}</b>\n#{answer_message}"
      #         end
      #       rescue => e
      #         answer.send_out "#{I18n.t('error')}"
      #       end

      protected

      def save_message(result_data = {})
        return unless @tg_user || @message
        return if result_data.empty?

        @tg_user.tg_account_messages.create!(result_data)
      end

      def on(command, param, &block)
        raise "No such param '#{param}'. Must be a one of #{MSG_TYPES}" unless MSG_TYPES.include?(param)

        @message_value = case param
                         when :text
                           respond.incoming_data.message.text
                         when :data
                           respond.incoming_data.message.data
                         else
                           raise "Can't find message for #{respond.incoming_data.message}, type: #{param}, available: #{MSG_TYPES}"
                         end

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
