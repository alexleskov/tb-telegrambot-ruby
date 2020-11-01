# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class CourseSession
        class Menu < Teachbase::Bot::Interfaces::Menu
          def main(course_sessions, pagination_options)
            pagination_options[:all_count] = course_sessions.size
            current_page = (pagination_options[:offset] / pagination_options[:limit]) + 1
            all_page_count = (pagination_options[:all_count] / pagination_options[:limit]) + 1

            @type = :menu_inline
            @disable_notification = true
            @slices_count = 2
            @mode ||= :edit_msg
            @text ||= ["#{create_title(title_params)}\n",
                       "#{build_list(course_sessions.limit(pagination_options[:limit]).offset(pagination_options[:offset]))}\n",
                       "#{I18n.t('page')} #{current_page} #{I18n.t('from')} #{all_page_count}"].join("\n")
            buttons_list = [build_pagination_button(:less, pagination_options),
                            build_pagination_button(:more, pagination_options)]
            buttons_list.compact!
            keyboard_param = { buttons: buttons_list }
            if buttons_list.empty? || (buttons_list.first.action_type == :more && buttons_list.size == 1)
              keyboard_param[:back_button] = back_button
            end
            @buttons = InlineCallbackKeyboard.collect(keyboard_param).raw
            self
          end

          def states
            @type = :menu_inline
            @slices_count = 2
            @buttons = state_buttons
            @mode ||= :none
            @text ||= "#{Emoji.t(:books)}<b>#{I18n.t('cs_list')}</b>"
            self
          end

          private

          def build_list(course_sessions)
            result = []
            course_sessions.each do |cs|
              result << cs.sign_open(cover_url: '', route: router.cs(path: :entity, id: cs.tb_id).link).to_s
            end
            return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if result.empty?

            result.join("\n")
          end

          def state_buttons
            buttons_actions = []
            Teachbase::Bot::CourseSession::STATES.each { |state| buttons_actions << router.cs(path: :list, p: [param: state.to_s]).link }
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(Teachbase::Bot::CourseSession::STATES.dup << "update", "cs_"),
                                     buttons_actions: buttons_actions << router.cs(path: :list, p: [param: :update]).link).raw
          end
        end
      end
    end
  end
end
