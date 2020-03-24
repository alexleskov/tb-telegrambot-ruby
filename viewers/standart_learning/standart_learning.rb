module Teachbase
  module Bot
    module Viewers
      module StandartLearning
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
                          #{I18n.t('active_courses')}: #{profile.active_courses_count}
                          #{I18n.t('archived_courses')}: #{profile.archived_courses_count}"
        end

        def print_course_state(state)
          answer.send_out "#{Emoji.t(:books)} <b>#{I18n.t("#{state}_courses").capitalize}</b>"
        end

        def print_courses_list(course_sessions)
          course_sessions.each do |cs|
            buttons = prepeate_cs_buttons(cs)
            menu.create(buttons: buttons,
                        type: :menu_inline,
                        mode: :none,
                        text: "#{show_breadcrumbs(:course, [:name],
                                                  course_icon_url: cs.icon_url,
                                                  course_name: cs.name)}",
                        slices_count: 2)
          end
        end

        def print_more_courses_button(params)
          more_button = InlineCallbackButton.more(command_prefix: "show_course_sessions_list:#{params[:state]}",
                                                  limit: params[:limit_count],
                                                  offset: params[:offset_num])
          menu.more(сs_count, offset_num, more_button)
        end

        private

        def prepeate_cs_buttons(cs)
          buttons_sign = ["open", "course_results"]
          callbacks_data = ["cs_sec_by_id:#{cs.tb_id}", "cs_info_id:#{cs.tb_id}"]
          InlineCallbackButton.g(buttons_sign: to_i18n(buttons_sign),
                                 callback_data: callbacks_data,
                                 emoji: [Emoji.t(:mortar_board), Emoji.t(:information_source)])
        end

      end
    end
  end
end