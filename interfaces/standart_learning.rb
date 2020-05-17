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
          answer.send_out(user.profile_info)
        end

        def print_course_state(state)
          answer.send_out("#{attach_emoji(state.to_sym)} <b>#{I18n.t("courses_#{state}").capitalize}</b>")
        end

        def print_course_stats_info(course_session)
          menu.back(course_session.stats_with_title(stages: %i[title info]))
        end

        def print_material(content)
          print_content_title(content)
          buttons = content.action_buttons
          if answer_content.respond_to?(content.content_type)
            answer_content.public_send(content.content_type, content.build_source)
          else
            print_link_content(content)
          end
          menu.content_main(buttons) unless buttons.empty?
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.error_code == 400
            print_link_content(content)
            menu.content_main(buttons) unless buttons.empty?
          else
            @logger.debug "Error: #{e}"
            answer.send_out(I18n.t('unexpected_error'))
          end
        end

        def print_content_title(content)
          answer.send_out(create_title(object: content,
                                       stages: %i[contents title]), disable_notification: true)
        end

        def print_link_content(content)
          answer_content.url(content.source, "#{I18n.t('open').capitalize}: #{content.name}")
        end

        def print_is_empty_by(params = {})
          answer.send_out "\n#{create_title(params)}
                           \n#{create_empty_msg}"
        end

        def menu_courses_list(course_sessions, params = {})
          course_sessions.each do |cs|
            params[:object] = cs
            menu.course_main(create_title(params), ["cs_sec_by_id:#{cs.tb_id}", "cs_info_id:#{cs.tb_id}"])
          end
        end

        def menu_choosing_course_state
          menu.course_states("#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>")
        end

        def menu_choosing_section(sections, params)
          cs = sections.first.course_session
          params[:object] = cs
          title = "#{create_title(params)}
                  #{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}"
          if sections.empty?
            menu_empty_msg(title, cs.back_button)
          else
            menu.section_main(title, params[:command_prefix], @tg_user.tg_account_messages)
          end
        end

        def menu_sections_by_option(sections, option)
          cs = sections.first.course_session
          title = create_title(object: cs, stages: %i[title sections menu], params: { state: option })
          menu_mode = option == :find_by_query_num ? :none : :edit_msg
          menu.back("#{title}
                    #{create_sections_msg_with_state(sections)}",
                    menu_mode)
        end

        def menu_section_contents(section, contents, params)
          params[:object] = section
          menu.create(buttons: create_content_buttons(contents) + section.course_session.back_button,
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
              buttons_sign << "#{attach_emoji(content_type)} #{content.name}"
              callbacks_data << "open_content:#{content_type}_by_csid:#{cs_tb_id}_secid:#{content.section_id}_objid:#{content.tb_id}"
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
