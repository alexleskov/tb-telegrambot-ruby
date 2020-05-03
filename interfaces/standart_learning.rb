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

        def print_courses_list(course_sessions, params = {})
          course_sessions.each do |cs|
            params[:object] = cs if params[:breadcrumbs]
            id = cs.tb_id
            menu.course_main(prepare_title(params), [ "cs_sec_by_id:#{id}", "cs_info_id:#{id}" ])
          end
        end

        def menu_choosing_course_state
          menu.course_states("#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>")
        end

        def print_update_status(status)
          text = case status.to_sym
                 when :in_progress
                   "#{Emoji.t(:arrows_counterclockwise)} <b>#{I18n.t('updating_data')}</b>"
                 when :success
                   "#{Emoji.t(:thumbsup)} #{I18n.t('updating_success')}"
                 else
                   "#{Emoji.t(:thumbsdown)} #{I18n.t('error')}"
                 end
          answer.send_out(text)
        end

        def print_sections_by_state(sections)
          mess = []
          sections.each do |section|
            mess << section.title_with_state(section.find_state)
          end
          return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if mess.empty?

          mess.join("\n")
        end

        def print_content(content, back_button = true)
          type = content.content_type
          print_content_title(content)
          answer_content.public_send(type, content.get_content) if answer_content.respond_to?(type)
          prepare_section_back_button(content.section) if back_button
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.error_code == 400
            @logger.debug "Error: #{e}"
            menu.open_url_by_object(content)
            prepare_section_back_button(content.section) if back_button
          else
            answer.send_out(I18n.t('unexpected_error'))
          end 
        end

        def print_content_title(content)
          answer.send_out(prepare_content_title(content), disable_notification: true) 
        end

        def menu_choosing_section(sections, params)
          if params[:breadcrumbs]
            params[:object] = sections.first.course_session
            params[:icon_url] = sections.first.course_session.icon_url
          end
          text = "#{prepare_title(params)}
                 \n#{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}"
          menu.section_main(text, params[:command_prefix], @tg_user.tg_account_messages)
        end

        def prepare_course_stats(cs, params = {})
          if params[:breadcrumbs]
            params[:object] = cs
            params[:icon_url] = cs.icon_url
          end
          "#{prepare_title(params)}#{cs.statistics}"
        end

        def prepare_content_buttons(contents, cs_tb_id)
          buttons_sign = []
          callbacks_data = []
          contents[:section_content].keys.each do |content_type|
            emoji = attach_emoji(content_type)
            content_type_group = contents[:section_content][content_type]
            content_type_group.each do |content|
              buttons_sign << "#{emoji} #{content.name}"
              callbacks_data << "open_content:#{content_type}_by_csid:#{cs_tb_id}_secid:#{content.section_id}_objid:#{content.tb_id}"
            end
          end
          InlineCallbackButton.g(buttons_sign: buttons_sign,
                                 callback_data: callbacks_data)
        end

        def prepare_section_back_button(section, mode = :none)
          menu.custom_back("/sec#{section.position}_cs#{section.course_session.tb_id}",
                           "#{I18n.t('back_to')} #{I18n.t('section2')} <b>\"#{section.name}\"</b>",
                           mode)
        end

        def to_course_sections_button(cs_tb_id)
          InlineCallbackButton.g(buttons_sign: [ I18n.t('back').to_s ],
                                 callback_data: [ "cs_sec_by_id:#{cs_tb_id}" ],
                                 emoji: [ :arrow_left ]) 
        end

        def prepare_content_title(content)
          "#{content.position}. #{attach_emoji(content.content_type.to_sym)} <b>#{content.name}</b>"
        end

        def prepare_title(params)
          return Emoji.t(:book) if params.empty?

          if params[:breadcrumbs]
            raise "Object not found for breadcrumbs creating" unless params[:object]

            object = params[:object]
            case params[:breadcrumbs]
              when :course
                #create_breadcrumbs(:course, params[:level], course_icon_url: object.icon_url, course_name: object.name)
                create_breadcrumbs(:course, params[:level], course_icon_url: params[:icon_url], course_name: object.name)
              when :section
                create_breadcrumbs(:course,
                                 [:name, :contents] + params[:level],
                                 course_name: object.name,
                                 section_menu: params[:menu_option],
                                 section: params[:section],
                                 content: params[:content])
              else
                raise "No such breadcrumbs source: '#{params[:breadcrumbs]}'"
              end
          else
            params[:text]
          end
        end

        def init_breadcrumbs(params)
          # TODO: Convert in Breadcrumbs class
          # cs = params[:course_session] || ""
          # section = params[:section] || ""
          # content = params[:section] || ""
          course_name = params[:course_name] || ""
          course_icon_url = params[:course_icon_url] || ""
          section_menu = params[:section_menu]
          section = params[:section]
          content = params[:content]
          if content
            content_name = content.name
            content_type = content.content_type.to_sym
            content_source = content.source
          end
          section_name = section ? print_section_title_by(section, :string) : nil
          section_menu_title = section_menu ? print_section_menu_title(section_menu) : nil
          { course: { name: "#{Emoji.t(:book)} <a href='#{course_icon_url}'>#{I18n.t('course')}</a>: #{course_name}",
                      info: "#{Emoji.t(:information_source)} #{I18n.t('information')}",
                      contents: "#{Emoji.t(:arrow_down)} #{I18n.t('course_sections')}",
                      section_menu: "#{Emoji.t(:open_file_folder)} #{section_menu_title}",
                      section: "#{section_name}",
                      sections: "#{Emoji.t(:open_file_folder)} #{I18n.t('section2').capitalize}",
                      content: "#{attach_emoji(content_type)} #{I18n.t('content').capitalize}: #{content_name}" }
          }
        end

        def print_is_empty_by(object, params = {})
          params[:object] = object if params[:breadcrumbs]
          answer.send_out "\n#{prepare_title(params)}
                           \n#{create_empty_msg}"
        end

        private

        def print_section_menu_title(menu_state)
          return unless menu_state || !menu_state.empty?

          I18n.t(menu_state.to_s).capitalize.to_s
        end

        def create_empty_msg
          "#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
        end

      end
    end
  end
end