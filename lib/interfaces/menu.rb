# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Menu < Teachbase::Bot::InterfaceController
        attr_accessor :buttons,
                      :back_button,
                      :slices_count,
                      :approve_button,
                      :answers_button,
                      :send_message_button,
                      :accounts_button

        attr_reader :type

        def initialize(params, entity)
          @back_button = params[:back_button]
          @approve_button = params[:approve_button]
          @answers_button = params[:answers_button]
          @accounts_button = params[:accounts_button]
          @send_message_button = params[:send_message_button]
          @buttons = params[:buttons]
          @slices_count = params[:slices_count]
          @type = params[:type]
          super(params, entity)
        end

        def show
          answer.menu.create(build_menu_options)
        end

        def hide
          answer.menu.hide(build_menu_options)
        end

        protected

        def build_accounts_button
          return unless accounts_button

          InlineCallbackButton.g(button_sign: I18n.t('accounts').to_s,
                                 callback_data: router.g(:main, :accounts).link)
        end

        def build_send_message_button
          return unless send_message_button
          InlineCallbackButton.g(button_sign: "#{I18n.t('send')} #{I18n.t('message').downcase}",
                                 callback_data: router.g(:main, :send_message, p: [u_id: entity.tb_id]).link)
        end

        def build_pagination_button(action, pagination_options)
          router_parameters = { param: route_params[:param], limit: pagination_options[:limit],
                                offset: build_pagination_button_params(action, pagination_options)}
          return unless router_parameters[:offset]
          InlineCallbackButton.public_send(action, button_sign: @button_sign,
                                                   callback_data: router.g(route_params[:route], route_params[:path],
                                                                           p: [router_parameters]).link)
        end

        def build_links_buttons(links_list)
          buttons_list = []
          links_list.each do |link_params|
            raise unless link_params.is_a?(Hash)

            link_params = replace_key_names(Teachbase::Bot::InterfaceController::LINK_ATTRS, link_params)
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

        def build_menu_options
          { text: text, type: type, slices_count: slices_count, mode: mode, buttons: buttons,
            disable_web_page_preview: disable_web_page_preview }
        end

        def init_commands
          answer.menu.command_list
        end
      end
    end
  end
end
