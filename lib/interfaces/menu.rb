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
          answer.menu.create(build_options)
        end

        def hide
          answer.menu.hide(build_options)
        end

        protected

        def build_pagination_button(action, pagination_options)
          @offset = pagination_options[:offset_num].to_i
          @limit = pagination_options[:limit_count].to_i
          @all_count = pagination_options[:all_count].to_i
          button_params = pagination_button_params(action)
          return unless button_params

          InlineCallbackButton.public_send(action, button_sign: @button_sign, callback_data: router.public_send(params[:object_type],
                                                                                                                path: params[:path],
                                                                                                                p: pagination_path_params).link)
        end

        def pagination_button_params(action)
          case action
          when :more
            @offset += @limit
            return if @offset >= @all_count

            @button_sign = I18n.t('forward').to_s
          when :less
            @offset -= @limit
            return if @offset < 0

            @button_sign = I18n.t('back').to_s
          else
            raise "No such pagination action: '#{action}'"
          end
        end

        def pagination_path_params
          path_params = [offset: @offset, lim: @limit]
          path_params = params[:param] ? path_params << { param: params[:param] } : path_params
        end

        def build_options
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