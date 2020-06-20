# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module StandartLearning
        include Viewers::Helper

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def print_user_profile(user)
          answer.text.send_out(user.profile_info)
        end

        def print_course_state(state)
          answer.text.send_out("#{attach_emoji(state.to_sym)} <b>#{I18n.t("courses_#{state}").capitalize}</b>")
        end

        def print_course_stats_info(course_session)
          answer.menu.back(text: course_session.statistics(stages: %i[title info]))
        end

        def menu_courses_list(course_sessions, params = {})
          course_sessions.each do |cs|
            params[:object] = cs
            menu_course_main(text: create_title(params),
                             callback_data: ["cs_sec_by_id:#{cs.tb_id}", "cs_info_id:#{cs.tb_id}"])
          end
        end

        def menu_choosing_course_state
          menu_course_states(text: "#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>",
                             command_prefix: "courses_")
        end

        def menu_choosing_section(sections, params)
          cs = sections.first.course_session
          params[:object] = cs
          title = "#{create_title(params)}#{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}"
          if sections.empty?
            menu_empty_msg(text: title, buttons: cs.back_button)
          else
            menu_section_main(text: title, command_prefix: params[:command_prefix], back_button: true)
          end
        end

        def menu_sections_by_option(sections, option)
          cs = sections.first.course_session
          title = create_title(object: cs, stages: %i[title sections menu], params: { state: option })
          menu_mode = option == :find_by_query_num ? :none : :edit_msg
          answer.menu.back(text: "#{title}#{create_sections_msg_with_state(sections)}", mode: menu_mode)
        end

        private

        def create_sections_msg_with_state(sections)
          mess = []
          sections.each do |section|
            mess << section.title_with_state(section.find_state)
          end
          return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if mess.empty?

          mess.join("\n")
        end
      end
    end
  end
end
