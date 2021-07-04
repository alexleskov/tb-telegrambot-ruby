# frozen_string_literal: true

module Teachbase
  module Bot
    class InterfaceController
      include Formatter

      attr_reader :answer, :entity, :router, :params
      attr_accessor :title_params, :route_params

      def initialize(params, entity)
        @params = params
        @title_params = params[:title_params]
        @route_params = params[:route_params]
        @entity = entity
        @answer = Teachbase::Bot::Interfaces.answers_controller
        @router = Teachbase::Bot::Router.new
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
          result << Phrase.new(user_comment).comment
        end
        result.join("\n")
      end

      def answers
        result = []
        entity.answers.order(created_at: :desc).each do |user_answer|
          build_attachments = user_answer.attachments? ? "#{attachments(user_answer)}\n" : nil
          build_comments = user_answer.comments? ? "\n#{sanitize_html(comments(user_answer))}\n" : nil
          result << "#{Phrase.new(user_answer).answer}\n\n#{build_attachments}#{build_comments}"
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

        "#{result}\n#{attachments(entity)}"
      end

      protected

      def on_empty_params
        @params[:text] ||= "#{title_params ? "#{create_title(title_params)}\n" : ''}#{Phrase.empty}"
      end

      # def cs_tb_id
      #   entity.is_a?(Teachbase::Bot::CourseSession) ? entity.tb_id : entity.course_session.tb_id
      # end
    end
  end
end
