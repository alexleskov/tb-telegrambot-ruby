module Teachbase
  module Bot
    module Interfaces
      module StandartLearning

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
          menu.back(create_course_stats_msg(course_session, stages: %i[title info]))
        end

        def print_update_status(status)
          answer.send_out(create_update_status_msg_by(status))
        end

        def print_material(content, back_button = true)
          buttons = [ create_material_approve_button(content) ]
          menu_text = "#{I18n.t('back_to')} #{I18n.t('section2')} <b>\"#{content.section.name}\"</b>"
          buttons = back_button ? buttons + create_section_back_button(content.section) : buttons
          print_content_title(content)
          if answer_content.respond_to?(content.content_type)
            answer_content.public_send(content.content_type, content.get_content)
          else 
            print_link_content(content)
          end
          menu_content_action(menu_text, buttons)
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.error_code == 400
            @logger.debug "Error: #{e}"
            print_link_content(content)
            menu_content_action(menu_text, buttons)
          else
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
            menu.course_main(create_title(params), [ "cs_sec_by_id:#{cs.tb_id}", "cs_info_id:#{cs.tb_id}" ])
          end
        end

        def menu_choosing_course_state
          menu.course_states("#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>")
        end

        def menu_content_action(text, buttons, mode = :none)
          menu.create(buttons: buttons, type: :menu_inline, disable_notification: true, mode: mode,
                      text: text)
        end

        def menu_choosing_section(sections, params)
          cs = sections.first.course_session
          params[:object] = cs
          title = "#{create_title(params)}
                  #{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}"
          if sections.empty?
            menu_empty_msg(title, create_sections_back_button(cs.tb_id))
          else
            menu.section_main(title, params[:command_prefix], @tg_user.tg_account_messages)
          end
        end

        def menu_sections_by_option(sections, option)
          cs = sections.first.course_session
          title = create_title(object: cs, stages: %i[title sections menu], params: { state: option })
          if sections.empty?
            menu_empty_msg(title, create_sections_back_button(cs.tb_id))
          else
            menu_mode = option == :find_by_query_num ? :none : :edit_msg
            menu.back("#{title}
                       #{create_sections_msg_with_state(sections)}",
                       menu_mode)
          end
        end

        def menu_empty_msg(text, buttons)
          menu.create(buttons: buttons,
                      text: "#{text}\n#{create_empty_msg}",
                      type: :menu_inline)
        end

        def menu_section_contents(section, contents, params)
          cs_tb_id = section.course_session.tb_id
          params[:object] = section
          menu.create(buttons: create_content_buttons(contents, cs_tb_id) + create_sections_back_button(cs_tb_id),
                      mode: :none,
                      type: :menu_inline,
                      text: create_title(params))
        end

        private

        def create_content_buttons(contents, cs_tb_id)
          buttons_sign = []
          callbacks_data = []
          contents.keys.each do |content_type|
            contents[content_type].each do |content|
              buttons_sign << "#{attach_emoji(content_type)} #{content.name}"
              callbacks_data << "open_content:#{content_type}_by_csid:#{cs_tb_id}_secid:#{content.section_id}_objid:#{content.tb_id}"
            end
          end
          InlineCallbackButton.g(buttons_sign: buttons_sign,
                                 callback_data: callbacks_data)
        end

        def create_section_back_button(section)
          InlineCallbackButton.custom_back("/sec#{section.position}_cs#{section.course_session.tb_id}")
        end

        def create_material_approve_button(material) # ADD APPROVE BUTON
          InlineCallbackButton.g(buttons_sign: [ I18n.t('approve').to_s ],
                                 callback_data: [ "approve_material_objid:#{material.tb_id}" ])
        end

        def create_sections_back_button(cs_tb_id)
          InlineCallbackButton.custom_back("cs_sec_by_id:#{cs_tb_id}")
        end

        def create_title(params)
          raise "Params is '#{params.class}'. Must be a Hash" unless params.is_a?(Hash)

          if params.keys.include?(:text)
            params[:text]
          else
            Breadcrumb.g(params[:object], params[:stages], params[:params])
          end
        end

        def create_sections_msg_with_state(sections)
          mess = []
          sections.each do |section|
            mess << section.title_with_state(section.find_state)
          end
          return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if mess.empty?

          mess.join("\n")
        end

        def create_course_stats_msg(cs, params = {})
          params[:object] = cs
          "#{create_title(params)}#{cs.statistics}"
        end

        def create_update_status_msg_by(status)
          case status.to_sym
          when :in_progress
            "#{Emoji.t(:arrows_counterclockwise)} <b>#{I18n.t('updating_data')}</b>"
          when :success
            "#{Emoji.t(:thumbsup)} #{I18n.t('updating_success')}"
          else
            "#{Emoji.t(:thumbsdown)} #{I18n.t('error')}"
          end
        end

        def create_empty_msg
          "#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
        end
      end
    end
  end
end