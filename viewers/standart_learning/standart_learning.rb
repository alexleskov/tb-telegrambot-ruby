module Teachbase
  module Bot
    module Viewers
      module StandartLearning
        CHOOSING_BUTTONS = %i[find_by_query_num show_avaliable show_unvaliable show_all]
        COURSE_BUTTONS = %w[open course_results]
        STATE_BUTTONS = %w[active archived update]

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def print_user_profile(user, profile)
          answer.send_out "<b>#{Emoji.t(:mortar_board)} #{I18n.t('profile_state')}</b>
                          \n  <a href='#{user.avatar_url}'>#{user.first_name} #{user.last_name}</a>
                          \n  #{Emoji.t(:school)} #{I18n.t('average_score_percent')}: #{profile.average_score_percent}%
                          \n  #{Emoji.t(:hourglass)} #{I18n.t('total_time_spent')}: #{profile.total_time_spent / 3600} #{I18n.t('hour')}
                          \n  #{Emoji.t(:green_book)} #{I18n.t('courses')}:
                          #{I18n.t('courses_active')}: #{profile.active_courses_count}
                          #{I18n.t('courses_archived')}: #{profile.archived_courses_count}"
        end

        def print_course_state(state)
          emoji_sign = case state.to_sym
                       when :active
                         :green_book
                       when :archived
                         :closed_book
                       end
          answer.send_out "#{Emoji.t(emoji_sign)} <b>#{I18n.t("courses_#{state}").capitalize}</b>"
        end

        def print_courses_list(course_sessions, params = {})
          course_sessions.each do |cs|
            params[:object] = cs if params[:breadcrumbs]
            menu.create(buttons: prepare_course_buttons(cs),
                        type: :menu_inline,
                        mode: :none,
                        text: prepare_title(params),
                        slices_count: 2)
          end
        end

        def print_course_stats(course_session, params = {})
          if params[:breadcrumbs]
            params[:object] = course_session
            params[:icon_url] = course_session.icon_url
          end
          "#{prepare_title(params)}
           \n #{Emoji.t(:runner)}#{I18n.t('started_at')}: #{print_course_time_by(:started_at, course_session)}
           \n #{Emoji.t(:alarm_clock)}#{I18n.t('deadline')}: #{print_course_time_by(:deadline, course_session)}
           \n #{Emoji.t(:chart_with_upwards_trend)}#{I18n.t('progress')}: #{course_session.progress}%
           \n #{Emoji.t(:star2)}#{I18n.t('complete_status')}: #{I18n.t("complete_status_#{course_session.complete_status}")}
           \n #{Emoji.t(:trophy)}#{I18n.t('success')}: #{I18n.t("success_#{course_session.success}")}"
        end

        def print_course_time_by(param, course_session)
          raise "Can't get time by param: '#{param}" unless course_session.respond_to?(param)

          time = course_session.public_send(param)
          sign_on_empty = param == :deadline ? "\u221e" : "-"
          time.nil? ? sign_on_empty : Time.parse(Time.at(time)
                                                     .strftime("%d.%m.%Y %H:%M"))
                                          .strftime("%d.%m.%Y %H:%M")
        end

        def print_is_empty_by(course_session, params = {})
          params[:object] = course_session if params[:breadcrumbs]
          answer.send_out "\n#{prepare_title(params)}
                           \n#{create_empty_msg}"
        end

        def create_empty_msg
          "#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
        end

        def print_section_menu_title(menu_state)
          return unless menu_state || !menu_state.empty?

          I18n.t(menu_state.to_s).capitalize.to_s
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

        def print_section_title_by(section, style)
          return unless section.is_a?(Teachbase::Bot::Section)

          emoji = if [:open, :section_unable, :section_delayed, :section_unpublish].include?(style)
                    attach_emoji(style)
                  else
                    Emoji.t(:open_file_folder)
                  end
          "#{emoji} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}"
        end

        def print_sections_by_status(sections, cs_id)
          mess = []
          sections.each do |section|
            string = if section.is_publish && section.is_available
                       "\n#{print_section_title_by(section, :open)}.\n<i>#{I18n.t('open')}</i>: /sec#{section.position}_cs#{cs_id}"
                     elsif section.is_publish && !section.is_available && !section.opened_at
                       "\n#{print_section_title_by(section, :section_unable)}\n<i>#{I18n.t('section_unable')}</i>."
                     elsif section.is_publish && !section.is_available && section.opened_at
                       "\n#{print_section_title_by(section, :section_delayed)}:\n<i>#{I18n.t('section_delayed')}</i>: <i>#{Time.at(section.opened_at).utc.strftime('%d.%m.%Y %H:%M')}.</i>"
                     elsif !section.is_publish
                       "\n#{print_section_title_by(section, :section_unpublish)}\n<i>#{I18n.t('section_unpublish')}</i>."
                     end
            mess << string
          end
          return "\n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>" if mess.empty?

          mess.join("\n")
        end

        def menu_choosing_section(sections, params)
          if params[:breadcrumbs]
            params[:object] = sections.first.course_session
            params[:icon_url] = sections.first.course_session.icon_url
          end
          command_prefix = params[:command_prefix]
          buttons = InlineCallbackButton.g(buttons_sign: to_i18n(CHOOSING_BUTTONS),
                                           callback_data: CHOOSING_BUTTONS,
                                           command_prefix: command_prefix,
                                           back_button: true,
                                           sent_messages: @tg_user.tg_account_messages)
          menu.create(buttons: buttons,
                      type: :menu_inline,
                      text: "#{prepare_title(params)}
                             \n#{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}",
                      slices_count: 3)
        end

        def menu_choosing_course_state
          prefix = "courses_"
          buttons = InlineCallbackButton.g(buttons_sign: to_i18n(STATE_BUTTONS, prefix),
                                           callback_data: STATE_BUTTONS,
                                           command_prefix: prefix,
                                           emoji: [ :green_book, :closed_book, :arrows_counterclockwise ] )
          menu.create(buttons: buttons,
                      mode: :none,
                      type: :menu_inline,
                      text: "#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>",
                      slices_count: 2)
        end

        def ask_enter_the_number(object)
          sign = case object
                 when :section
                   I18n.t('section2')
                 else
                   raise "Can't ask number object: '#{object}'"
                 end
          answer.send_out "#{Emoji.t(:pencil2)} <b>#{I18n.t('enter_the_number')} #{sign}:</b>"
        end

        def prepare_course_buttons(cs)
          callbacks_data = [ "cs_sec_by_id:#{cs.tb_id}", "cs_info_id:#{cs.tb_id}" ]
          InlineCallbackButton.g(buttons_sign: to_i18n(COURSE_BUTTONS),
                                 callback_data: callbacks_data,
                                 emoji: [ :mortar_board, :information_source ])
        end

        def prepare_content_buttons(contents, cs_id)
          buttons_sign = []
          callbacks_data = []
          contents[:section_content].keys.each do |content_type|
            emoji = attach_emoji(content_type)
            content_type_group = contents[:section_content][content_type]
            content_type_group.each do |content|
              buttons_sign << "#{emoji} #{content.name}"
              callbacks_data << "open_content:#{content_type}_by_csid:#{cs_id}_secid:#{content.section_id}_objid:#{content.tb_id}"
            end
          end
          InlineCallbackButton.g(buttons_sign: buttons_sign,
                                 callback_data: callbacks_data)
        end

        def prepare_sections_button(cs_id, emoji)
          InlineCallbackButton.g(buttons_sign: [ I18n.t('back').to_s ],
                                 callback_data: [ "cs_sec_by_id:#{cs_id}" ],
                                 emoji: [ :arrow_left ])
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

      end
    end
  end
end