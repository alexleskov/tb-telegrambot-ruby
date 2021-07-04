# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Menu < Teachbase::Bot::Interfaces::Menu
          def list(course_sessions, pagination_options = {})
            @params[:type] = :menu_inline
            @params[:disable_notification] = true
            @params[:slices_count] = 2
            @params[:mode] ||= :edit_msg
            @params[:text] ||= ["#{create_title(title_params)}\n",
                       "#{build_list(course_sessions)}\n"]
            buttons_list = pagination_buttons(pagination_options)
            buttons_list.compact!
            keyboard_param = { buttons: buttons_list }
            if buttons_list.empty? || (buttons_list.first.action_type == :more && buttons_list.size == 1)
              keyboard_param[:back_button] = back_button
            end
            @params[:text] = @params[:text].join("\n")
            @params[:buttons] = InlineCallbackKeyboard.collect(keyboard_param).raw
            self
          end

          def states
            @params[:type] = :menu_inline
            @params[:slices_count] = 2
            @params[:buttons] = state_buttons
            @params[:mode] ||= :none
            @params[:text] ||= Phrase.courses_list
            self
          end

          private

          def pagination_buttons(pagination_options)
            return [] if pagination_options.empty?

            current_page = (pagination_options[:offset] / pagination_options[:limit]) + 1
            all_page_count = (pagination_options[:all_count].to_f / pagination_options[:limit].to_f).ceil
            @params[:text] << Phrase.page_number(current_page, all_page_count)
            [build_pagination_button(:less, pagination_options), build_pagination_button(:more, pagination_options)]
          end

          def build_list(course_sessions)
            result = []
            course_sessions.each do |cs|
              result << cs.sign_open(cover_url: '', route: router.g(:cs, :root, id: cs.tb_id).link).to_s
            end
            result.join("\n\n")
          end

          def state_buttons
            buttons_actions = []
            Teachbase::Bot::CourseSession::STATES.each do |state|
              buttons_actions << router.g(:cs, :list, p: [param: state.to_s]).link
            end
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(Teachbase::Bot::CourseSession::STATES.dup, "cs_"),
                                     buttons_actions: buttons_actions,
                                     back_button: back_button).raw
          end
        end
      end
    end
  end
end
