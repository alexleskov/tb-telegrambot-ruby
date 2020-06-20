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
      back_button_param = params[:back_button] || true
      approve_button_param = params[:approve_button] || true
      show_answers_button_param = params[:show_answers_button]
      back = back_button_param ? build_to_section_button : []
      approve = course_session.active? && approve_button_param ? build_approve_button : []
      show_answers = show_answers_button_param ? build_show_answers_button : []
      approve + show_answers + back
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

    def build_to_section_button
      section.back_button
    end

    def build_show_answers_button
      answers && !answers.empty? ? build_show_answer_button : []
    end
  end
end
