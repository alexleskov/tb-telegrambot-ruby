# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Menu < Teachbase::Bot::InterfaceController
        attr_accessor :buttons, :back_button, :slices_count, :approve_button, :answers_button
        attr_reader :type

        def initialize(params, entity)
          @back_button = params[:back_button]
          @approve_button = params[:approve_button]
          @answers_button = params[:answers_button]
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

        def build_pagination_button(action, pagination_options)
          router_parameters = { offset: build_pagination_button_params(action, pagination_options),
                                limit: pagination_options[:limit] }
          return unless router_parameters[:offset]

          router_parameters[:param] = path_params[:param] if path_params[:param]
          InlineCallbackButton.public_send(action, button_sign: @button_sign,
                                                   callback_data: router.public_send(path_params[:object_type], path: path_params[:path],
                                                                                                                p: [router_parameters]).link)
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
