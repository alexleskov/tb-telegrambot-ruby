module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def show_profile_state
          profile = appshell.profile_state
          user = appshell.data_loader.user

          answer.send_out "<b>#{Emoji.t(:mortar_board)} #{I18n.t('profile_state')}</b>
          \n  <a href='#{user.avatar_url}'>#{user.first_name} #{user.last_name}</a>
          \n  #{Emoji.t(:school)} #{I18n.t('average_score_percent')}: #{profile.average_score_percent}%
          \n  #{Emoji.t(:hourglass)} #{I18n.t('total_time_spent')}: #{profile.total_time_spent / 3600} #{I18n.t('hour')}
          \n  #{Emoji.t(:green_book)} #{I18n.t('courses')}:
          #{I18n.t('active_courses')}: #{profile.active_courses_count}
          #{I18n.t('archived_courses')}: #{profile.archived_courses_count}"
        end

        def show_course_sessions_list(state)
          raise "No such course state: #{state}" unless [:active, :archived].include?(state)

          course_sessions = appshell.course_sessions_list(state)
          if course_sessions.empty?
            answer.send_out "#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
          else
            course_sessions.each do |course_session|
              buttons = [[text: I18n.t('open').to_s, callback_data: "cs_sec_by_id:#{course_session.tb_id}"],
                         [text: I18n.t('course_results').to_s, callback_data: "cs_info_id:#{course_session.tb_id}"]]
              menu.create(buttons: buttons,
                          type: :menu_inline,
                          text: "#{Emoji.t(:book)} <b>#{I18n.t("#{state}_courses").capitalize}</b>
                                 \n<a href='#{course_session.icon_url}'>#{I18n.t('course')}</a>: <b>#{course_session.name}</b>",
                          slices_count: 2)
            end
          end
        rescue RuntimeError => e
          answer.send_out I18n.t('error').to_s
        end

        def show_course_session_info(cs_id)
          course_session = appshell.course_session_info(cs_id)
          deadline = course_session.deadline.nil? ? "\u221e" : Time.at(course_session.deadline).utc.strftime("%d.%m.%Y %H:%M")
          started_at = course_session.started_at.nil? ? "-" : Time.at(course_session.started_at).utc.strftime("%d.%m.%Y %H:%M")
          text = "#{Emoji.t(:book)} #{I18n.t('course')}: #{course_session.name} - #{Emoji.t(:information_source)} <b>#{I18n.t('information')}</b>
                  \n  #{Emoji.t(:runner)}#{I18n.t('started_at')}: #{started_at}
                  \n  #{Emoji.t(:alarm_clock)}#{I18n.t('deadline')}: #{deadline}
                  \n  #{Emoji.t(:chart_with_upwards_trend)}#{I18n.t('progress')}: #{course_session.progress}%
                  \n  #{Emoji.t(:star2)}#{I18n.t('complete_status')}: #{I18n.t("complete_status_#{course_session.complete_status}")}
                  \n  #{Emoji.t(:trophy)}#{I18n.t('success')}: #{I18n.t("success_#{course_session.success}")}"
          menu.create(buttons: [menu.inline_back_button],
                      type: :menu_inline,
                      text: text)
        rescue RuntimeError => e
          answer.send_out I18n.t('error').to_s
        end

        def show_sections_list_l1(cs_id)
          sections = appshell.course_session_sections(cs_id)
          cs_name = appshell.course_session_info(cs_id).name
          if sections.empty?
            answer.send_out "\n#{Emoji.t(:book)} #{I18n.t('course')}: <b>#{cs_name} - #{Emoji.t(:arrow_down)} #{I18n.t('course_sections')}</b>
                             \n#{Emoji.t(:soon)} <i>#{I18n.t('empty')}</i>"
          else
            params = %i[find_by_query_num show_avaliable show_unvaliable show_all]
            buttons = menu.
                      create_inline_buttons(params, "show_sections_by_csid:#{cs_id}_param:") << menu.inline_back_button
            menu.create(buttons: buttons,
                        type: :menu_inline,
                        text: "#{Emoji.t(:book)} #{I18n.t('course')}: #{cs_name} - #{Emoji.t(:arrow_down)} #{I18n.t('course_sections')} - #{Emoji.t(:page_facing_up)} <b>#{I18n.t('section2').capitalize}</b>
                               \n#{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}",
                        slices_count: 3)
          end
        end

        def show_sections(cs_id, param)
          sections_bd = appshell.data_loader.get_cs_sec_list(cs_id)
          return answer.empty_message if sections_bd.empty?

          cs_name = appshell.course_session_info(cs_id).name
          sections = case param
                     when :find_by_query_num
                       menu_mode = :none
                       title_sign = "#{I18n.t('find_by_query_num').capitalize} #{I18n.t('section2')}"
                       answer.send_out "#{Emoji.t(:pencil2)} <b>#{I18n.t('enter_the_number')} #{I18n.t('section2')}:</b>"
                       section_number = appshell.request_data(:string)
                       sections_bd.where(position: section_number)
                     when :show_all
                       title_sign = I18n.t('show_all').capitalize.to_s
                       sections_bd
                     when :show_avaliable
                       title_sign = I18n.t('show_avaliable').capitalize.to_s
                       sections_bd.where(is_available: true, is_publish: true)
                     when :show_unvaliable
                       title_sign = I18n.t('show_unvaliable').capitalize.to_s
                       sections_bd.where(is_available: false)
                     else
                       raise "No such param: '#{param}' for showing sections"
                     end

          menu.create(buttons: [menu.inline_back_button],
                      mode: menu_mode || :edit_msg,
                      type: :menu_inline,
                      text: "#{Emoji.t(:book)} #{I18n.t('course')}: #{cs_name} - #{Emoji.t(:arrow_down)} #{I18n.t('course_sections')} - #{Emoji.t(:page_facing_up)} <b>#{title_sign}</b>
                             #{group_sections_by_status(sections, cs_id).join("\n")}")
        rescue RuntimeError => e
          answer.send_out I18n.t('error').to_s
        end

        # def show_section_by(option, query, sections) ; end

        def update_course_sessions
          answer.send_out "#{Emoji.t(:arrows_counterclockwise)} <b>#{I18n.t('updating_data')}</b>"
          appshell.update_all_course_sessions_list
          answer.send_out "#{Emoji.t(:thumbsup)} #{I18n.t('updating_success')}"
        end

        def course_list_l1
          buttons = [[text: I18n.t('active_courses').capitalize, callback_data: "active_courses"],
                     [text: I18n.t('archived_courses').capitalize, callback_data: "archived_courses"],
                     [text: "#{Emoji.t(:arrows_counterclockwise)} #{I18n.t('update_course_sessions')}", callback_data: "update_course_sessions"]]
          menu.create(buttons: buttons,
                      mode: :none,
                      type: :menu_inline,
                      text: "#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>",
                      slices_count: 2)
        end

        def match_data
          on %r{signin} do
            signin
          end

          on %r{edit_settings} do
            edit_settings
          end

          on %r{^settings:localization} do
            choose_localization
          end

          on %r{^language_param:} do
            @message_value =~ %r{^language_param:(\w*)}
            change_language($1)
          end

          on %r{settings:scenario} do
            choose_scenario
          end

          on %r{^scenario_param:} do
            @message_value =~ %r{^scenario_param:(\w*)}
            mode = $1
            change_scenario(mode)
            answer.send_out "#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t('scenario')}: <b>#{I18n.t(mode)}</b>"
          end

          on %r{archived_courses} do
            show_course_sessions_list(:archived)
          end

          on %r{active_courses} do
            show_course_sessions_list(:active)
          end

          on %r{update_course_sessions} do
            update_course_sessions
          end

          on %r{^cs_info_id:} do
            @message_value =~ %r{^cs_info_id:(\d*)}
            show_course_session_info($1)
          end

          on %r{^cs_sec_by_id:} do
            @message_value =~ %r{^cs_sec_by_id:(\d*)}
            show_sections_list_l1($1)
          end

          on %r{^show_sections_by_csid:} do
            @message_value =~ %r{^show_sections_by_csid:(\d*)_param:(\w*)}
            show_sections($1, $2.to_sym)
          end
=begin
          on %r{^show_section_by_option:} do
            @message_value =~ %r{^show_section_by_option:(\w*)_q:(\w*)}
          end
=end
        end
        
        # def match_text_action ; end
        
        private

        def group_sections_by_status(sections, cs_id)
          mess = []
          sections.each do |section|
            string = if section.is_publish && section.is_available
                       "\n#{Emoji.t(:arrow_forward)} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n#{I18n.t('open')}: /sec#{section.position}_cs#{cs_id}"
                     elsif section.is_publish && !section.is_available && !section.opened_at
                       "\n#{Emoji.t(:no_entry_sign)} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n<i>#{I18n.t('section_unable')}.</i>"
                     elsif section.is_publish && !section.is_available && section.opened_at
                       "\n#{Emoji.t(:no_entry_sign)} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n<i>#{I18n.t('section_delayed')} #{Time.at(section.opened_at).utc.strftime('%d.%m.%Y %H:%M')}.</i>"
                     elsif !section.is_publish
                       "\n#{Emoji.t(:x)} <b>#{I18n.t('section')} #{section.position}:</b> #{section.name}
                        \n<i>#{I18n.t('section_unpublish')}.</i>"
                     end
            mess << string
          end
          return answer.empty_message if mess.empty?

          mess
        end

      end
    end
  end
end
