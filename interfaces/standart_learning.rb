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
          answer.menu.back(course_session.stats_with_title(stages: %i[title info]))
        end

        def print_content_title(content)
          answer.text.send_out(create_title(object: content,
                                       stages: %i[contents title]), disable_notification: true)
        end

        def print_is_empty_by(params = {})
          answer.text.send_out "\n#{create_title(params)}
                           \n#{create_empty_msg}"
        end

        def menu_courses_list(course_sessions, params = {})
          course_sessions.each do |cs|
            params[:object] = cs
            answer.menu.course_main(create_title(params), ["cs_sec_by_id:#{cs.tb_id}", "cs_info_id:#{cs.tb_id}"])
          end
        end

        def menu_choosing_course_state
          answer.menu.course_states("#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>")
        end

        def menu_choosing_section(sections, params)
          cs = sections.first.course_session
          params[:object] = cs
          title = "#{create_title(params)}
                  #{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}"
          if sections.empty?
            menu_empty_msg(title, cs.back_button)
          else
            answer.menu.section_main(title, params[:command_prefix], @tg_user.tg_account_messages)
          end
        end

        def menu_sections_by_option(sections, option)
          cs = sections.first.course_session
          title = create_title(object: cs, stages: %i[title sections menu], params: { state: option })
          menu_mode = option == :find_by_query_num ? :none : :edit_msg
          answer.menu.back("#{title}
                    #{create_sections_msg_with_state(sections)}",
                    menu_mode)
        end

        def menu_section_contents(section, contents, params)
          params[:object] = section
          answer.menu.create(buttons: create_content_buttons(contents) + section.course_session.back_button,
                             mode: :none,
                             type: :menu_inline,
                             text: create_title(params))
        end

        private

        def create_content_buttons(contents)
          buttons_sign = []
          callbacks_data = []
          contents.keys.each do |content_type|
            contents[content_type].each do |content|
              cs_tb_id = content.course_session.tb_id
              object_type = Teachbase::Bot::OBJECTS_TYPES[content_type]
              buttons_sign << "#{content.button_sign(object_type)}"
              callbacks_data << "open_content:#{object_type}_by_csid:#{cs_tb_id}_secid:#{content.section_id}_objid:#{content.tb_id}"
            end
          end
          InlineCallbackButton.g(buttons_sign: buttons_sign,
                                 callback_data: callbacks_data)
        end

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
