# frozen_string_literal: true

module Teachbase
  module Bot
    class InterfaceController
      include Formatter

      attr_reader :params, :answer, :entity

      def initialize(params, answer, entity)
        @params = params
        @answer = answer
        @entity = entity
      end

      def sing_on_empty
        "<b>#{I18n.t('empty')}</b>"
      end

      def sign_on_error
        "<b>#{I18n.t('error')}</b>"
      end

      def create_title(options)
        params[:object] ||= entity
        if options.keys.include?(:text)
          options[:text]
        else
          raise unless params[:object] && !options.empty?

          Breadcrumb.g(params[:object], options[:stages], options[:params])
        end
      end

      def button_sign(cont_type, object)
        "#{attach_emoji(cont_type)} #{attach_emoji(object.status)} #{object.name}"
      end

      def attachments(object)
        result = ["#{Emoji.t(:bookmark_tabs)} #{to_italic(I18n.t('attachments').capitalize)}"]
        object.attachments.each_with_index do |attach, ind|
          result << "#{ind + 1}. #{attach_emoji(attach.category)}#{to_url_link(attach.url, attach.name)}"
        end
        result.join("\n")
      end

      def comments(object)
        result = ["#{Emoji.t(:lips)} #{to_italic(I18n.t('comments').capitalize)}"]
        object.comments.each do |comment|
          result << "#{comment.user_name} #{I18n.t('commented').downcase}:
                     \"#{comment.text}\""
        end
        result.join("\n")
      end

      def answers
        result = []
        entity.answers.order(created_at: :desc).each do |answer|
          build_attachments = answer.attachments? ? "#{attachments(answer)}\n" : ""
          build_comments = answer.comments? ? "\n#{comments(answer)}\n" : ""
          result << "<b>#{I18n.t('answer').capitalize} №#{answer.attempt}. #{I18n.t('state').capitalize}: #{attach_emoji(answer.status)} #{to_italic(I18n.t(answer.status).capitalize)}</b>
                     <pre>#{answer.text}</pre>\n\n#{build_attachments}#{build_comments}"
        end
        result.join("\n")
      end

      def description
        return "" unless entity.description && !entity.description.empty?

        msg = "#{Emoji.t(:scroll)} #{to_bolder(I18n.t('description'))}:\n#{sanitize_html(entity.description)}\n\n"
        return msg unless entity.respond_to?("attachments?") && entity.attachments?

        "#{msg}#{attachments(entity)}"
      end

      def action_buttons
        params[:back_button] ||= true
        buttons = [build_show_answers_button, build_approve_button, build_to_section_button]
        InlineCallbackKeyboard.collect(buttons: buttons).raw
      end

      protected

      def build_approve_button; end

      def build_show_answers_button
        return unless entity.respond_to?(:answers)
        return unless entity.answers && !entity.answers.empty? && @params[:show_answers_button] && entity.course_session.active?

        InlineCallbackButton.g(button_sign: "#{I18n.t('show')} #{I18n.t('answers').downcase}",
                               callback_data: "answers_task_by_csid:#{cs_tb_id}_objid:#{entity.tb_id}",
                               emoji: :speech_balloon)
      end

      def build_to_section_button
        return unless @params[:back_button]

        entity.section.back_button
      end

      def cs_tb_id
        entity.course_session.tb_id
      end

      def sign_by_object_type(type)
        case type.to_sym
        when :section
          I18n.t('section2')
        else
          raise "No such sign for object type: '#{type}'"
        end
      end

      def sign_by_status(status)
        case status.to_sym
        when :in_progress
          "#{Emoji.t(:arrows_counterclockwise)} #{to_bolder(I18n.t('updating_data'))}"
        when :success
          "#{Emoji.t(:thumbsup)} #{I18n.t('updating_success')}"
        else
          "#{Emoji.t(:thumbsdown)} #{sign_on_error}"
        end
      end
    end
  end
end
