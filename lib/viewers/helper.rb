# frozen_string_literal: true

module Viewers
  module Helper
    def create_title(params)
      raise "Params is '#{params.class}'. Must be a Hash" unless params.is_a?(Hash)

      if params.keys.include?(:text)
        params[:text]
      else
        Breadcrumb.g(params[:object], params[:stages], params[:params])
      end
    end

    def action_buttons(params = {})
      @params = params
      params[:back_button] ||= true
      params[:approve_button] ||= true

      buttons = [build_show_answers_button, build_approve_button, build_to_section_button]
      keyboard = InlineCallbackKeyboard.collect(buttons: buttons).raw
      keyboard
    end

    def button_sign(cont_type)
      "#{attach_emoji(cont_type)} #{name} #{attach_emoji(status)}"
    end

    def object_attachments(object)
      attachments = ["#{Emoji.t(:bookmark_tabs)} <i>#{I18n.t('attachments').capitalize}</i>"]
      object.attachments.each_with_index do |attach, ind|
        attachments << "#{ind + 1}. #{attach_emoji(attach.category)}#{to_url_link(attach.url, attach.name)}"
      end
      attachments.join("\n")
    end

    def object_comments(object)
      comments = ["#{Emoji.t(:lips)} <i>#{I18n.t('comments').capitalize}</i>"]
      object.comments.each do |comment|
        comments << "#{comment.user_name} #{I18n.t('commented').downcase}:
                     \"#{comment.text}\""
      end
      comments.join("\n")
    end

    private

    def build_show_answers_button
      return unless respond_to?(:answers)
      return unless answers && !answers.empty? && @params[:show_answers_button] && course_session.active?

      InlineCallbackButton.g(button_sign: "#{I18n.t('show')} #{I18n.t('answers').downcase}",
                             callback_data: "answers_task_by_csid:#{cs_tb_id}_objid:#{tb_id}",
                             emoji: :speech_balloon)
    end

    def build_to_section_button
      return unless @params[:back_button]

      section.back_button
    end
  end
end
