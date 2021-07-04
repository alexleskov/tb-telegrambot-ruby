# frozen_string_literal: true

module Teachbase
  module Bot
    class InterfaceController
      include Formatter

      attr_reader :answer, :entity, :router, :params
      attr_accessor :title_params,
                    :route_params,
                    :back_button,
                    :approve_button,
                    :answers_button,
                    :send_message_button,
                    :accounts_button,
                    :open_button

      def initialize(params, entity)
        @params = params
        @back_button = params[:back_button]
        @title_params = params[:title_params]
        @route_params = params[:route_params]
        @approve_button = params[:approve_button]
        @answers_button = params[:answers_button]
        @accounts_button = params[:accounts_button]
        @open_button = params[:open_button]
        @send_message_button = params[:send_message_button]
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

      def build_accounts_button
        return unless accounts_button

        InlineCallbackButton.g(button_sign: I18n.t('accounts').to_s, callback_data: router.g(:main, :accounts).link)
      end

      def build_send_message_button
        return unless send_message_button

        InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('message').downcase}",
                               callback_data: router.g(:main, :send_message, p: [u_id: entity.tb_id]).link)
      end

      def build_pagination_button(action, pagination_options)
        router_parameters = { param: route_params[:param], limit: pagination_options[:limit],
                              offset: build_pagination_button_params(action, pagination_options) }
        return unless router_parameters[:offset]

        InlineCallbackButton.public_send(action, button_sign: @button_sign,
                                                 callback_data: router.g(route_params[:route], route_params[:path],
                                                                         p: [router_parameters]).link)
      end

      def build_links_buttons(links_list)
        buttons_list = []
        links_list.each do |link_params|
          raise unless link_params.is_a?(Hash)

          link_params = Attribute.replace_key_names(Teachbase::Bot::Profile::LINK_ATTRS, link_params)
          buttons_list << InlineUrlButton.to_open(link_params["source"], link_params["title"])
        end
        buttons_list
      end

      def build_pagination_button_params(action, pagination_options)
        case action
        when :more
          offset = pagination_options[:offset] + pagination_options[:limit]
          return if offset >= pagination_options[:all_count]

          @button_sign = I18n.t('forward').to_s
        when :less
          offset = pagination_options[:offset] - pagination_options[:limit]
          return if offset < 0

          @button_sign = I18n.t('back').to_s
        else
          raise "No such pagination action: '#{action}'"
        end
        offset
      end

      # def cs_tb_id
      #   entity.is_a?(Teachbase::Bot::CourseSession) ? entity.tb_id : entity.course_session.tb_id
      # end
    end
  end
end
