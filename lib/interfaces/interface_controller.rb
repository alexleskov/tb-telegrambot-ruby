# frozen_string_literal: true

module Teachbase
  module Bot
    class InterfaceController
      include Formatter

      LINK_ATTRS = { "url" => "source", "label" => "title" }.freeze

      attr_reader :answer, :entity, :router
      attr_accessor :text,
                    :mode,
                    :disable_web_page_preview,
                    :disable_notification,
                    :title_params,
                    :path_params

      def initialize(params, entity)
        @entity = entity
        @answer = Teachbase::Bot::Interfaces.answers_controller
        @router = Teachbase::Bot::Routers.new
        @text = params[:text]
        @mode = params[:mode]
        @disable_web_page_preview = params[:disable_web_page_preview]
        @disable_notification = params[:disable_notification] || false
        @title_params = params[:title_params]
        @path_params = params[:path_params]
      end

      def sing_on_empty
        "<b>#{I18n.t('empty')}</b>"
      end

      def sign_on_error
        "<b>#{I18n.t('error')}</b>"
      end

      def sign_by_object_type(object_type)
        case object_type.to_sym
        when :section
          I18n.t('section2')
        else
          raise "No such sign for object type: '#{object_type}'"
        end
      end

      def sign_entity_status
        "<b>#{I18n.t('state').capitalize}: #{attach_emoji(entity.status)} #{to_italic(I18n.t(entity.status).capitalize)}</b>"
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

      def create_title(options)
        options[:object] ||= entity
        if options.keys.include?(:text)
          options[:text]
        else
          return unless options[:object] && !options.empty?

          Breadcrumb.g(options[:object], options[:stages], options[:params])
        end
      end

      def attachments(object)
        result = ["#{Emoji.t(:bookmark_tabs)} #{to_italic(I18n.t('attachments').capitalize)}"]
        object.attachments.each_with_index do |attach, ind|
          result << "#{ind + 1}. #{to_url_link(attach.url, attach.name)}"
        end
        result.join("\n")
      end

      def comments(object)
        result = ["#{Emoji.t(:lips)} #{to_italic(I18n.t('comments').capitalize)}"]
        object.comments.order(:id).each do |comment|
          result << "<a href='#{comment.avatar_url}'>#{comment.user_name}</a> (#{Time.parse(Time.at(comment.tb_created_at).strftime('%d.%m.%Y %H:%M'))
                                                                                             .strftime('%d.%m.%Y %H:%M')}):
                     — \"#{to_italic(comment.text)}\"\n"
        end
        result.join("\n")
      end

      def answers
        result = []
        entity.answers.order(created_at: :desc).each do |user_answer|
          build_attachments = user_answer.attachments? ? "#{attachments(user_answer)}\n" : nil
          build_comments = user_answer.comments? ? "\n#{sanitize_html(comments(user_answer))}\n" : nil
          result << "<b>#{I18n.t('answer').capitalize} №#{user_answer.attempt}. #{I18n.t('state').capitalize}: #{attach_emoji(user_answer.status)} #{to_italic(I18n.t(user_answer.status).capitalize)}</b>
                     \"#{sanitize_html(user_answer.text)}\"\n\n#{build_attachments}#{build_comments}"
        end
        result.join("\n")
      end

      def description
        return if entity.description.nil? || sanitize_html(entity.description).strip.empty?

        result = "\n#{sanitize_html(entity.description)}"
        return result unless entity.respond_to?("attachments?") && entity.attachments?

        "#{result}\n\n#{attachments(entity)}"
      end

      protected

      def replace_key_names(cnames_hash, hash_on_replace)
        cnames_hash.each do |old_key, new_key|
          next unless hash_on_replace[old_key]

          hash_on_replace[new_key.to_s] = hash_on_replace.delete(old_key)
        end
        hash_on_replace
      end

      def on_empty_params
        title = title_params ? "#{create_title(title_params)}\n" : ""
        @text ||= "#{title}#{sing_on_empty}"
      end

      def cs_tb_id
        entity.is_a?(Teachbase::Bot::CourseSession) ? entity.tb_id : entity.course_session.tb_id
      end
    end
  end
end
