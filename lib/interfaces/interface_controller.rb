# frozen_string_literal: true

module Teachbase
  module Bot
    class InterfaceController
      include Formatter
      include Phrase

      attr_reader :answer, :entity, :router
      attr_accessor :text,
                    :mode,
                    :disable_web_page_preview,
                    :disable_notification,
                    :title_params,
                    :route_params

      def initialize(params, entity)
        @entity = entity
        @answer = Teachbase::Bot::Interfaces.answers_controller
        @router = Teachbase::Bot::Router.new
        @text = params[:text]
        @mode = params[:mode]
        @disable_web_page_preview = params[:disable_web_page_preview]
        @disable_notification = params[:disable_notification] || false
        @title_params = params[:title_params]
        @route_params = params[:route_params]
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
        result = [Phrase.attachments]
        object.attachments.each_with_index do |attach, ind|
          result << "#{ind + 1}. #{to_url_link(attach.url, attach.name)}"
        end
        result.join("\n")
      end

      def comments(object)
        result = [Phrase.comments]
        object.comments.order(:id).each do |user_comment|
          result << Phrase.user_comment(user_comment)
        end
        result.join("\n")
      end

      def answers
        result = []
        entity.answers.order(created_at: :desc).each do |user_answer|
          build_attachments = user_answer.attachments? ? "#{attachments(user_answer)}\n" : nil
          build_comments = user_answer.comments? ? "\n#{sanitize_html(comments(user_answer))}\n" : nil
          result << "#{Phrase.user_answer(user_answer)}\n\n#{build_attachments}#{build_comments}"
        end
        result.join("\n")
      end

      def description
        result =
          if entity.respond_to?(:content) && entity.content && !entity.content.empty?
            EditorJs.new(entity.content).parse.render
          elsif entity.description && !sanitize_html(entity.description).strip.empty?
            "\n#{sanitize_html(entity.description)}"
          end
        return result unless entity.respond_to?("attachments?") && entity.attachments?

        "#{result}\n\n#{attachments(entity)}"
      end

      protected

      def on_empty_params
        title = title_params ? "#{create_title(title_params)}\n" : ""
        @text ||= "#{title}#{Phrase.empty}"
      end

      # def cs_tb_id
      #   entity.is_a?(Teachbase::Bot::CourseSession) ? entity.tb_id : entity.course_session.tb_id
      # end
    end
  end
end
