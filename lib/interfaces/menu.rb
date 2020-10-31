# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Menu < Teachbase::Bot::InterfaceController

        attr_accessor :buttons, :back_button, :slices_count
        attr_reader :type

        def initialize(params, entity)
          @back_button = params[:back_button]
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
          @path_parameters = {}
          @path_parameters[:offset] = build_pagination_button_params(action, pagination_options)
          @path_parameters[:limit] = pagination_options[:limit]
          return unless @path_parameters[:offset]

          @path_parameters[:param] = params[:param] if params[:param]
          InlineCallbackButton.public_send(action, button_sign: @button_sign, callback_data: router.public_send(params[:object_type],
                                                                                                                path: params[:path],
                                                                                                                p: [@path_parameters]).link)
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