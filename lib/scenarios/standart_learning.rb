module Teachbase
  module Bot
    module Scenarios
      module StandartLearning
        include Teachbase::Bot::Scenarios::Base

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods ; end

        def show_profile_state
          appshell.data_loader.call_profile
          user = appshell.data_loader.user
          profile = appshell.data_loader.profile
          answer.send_out "<b>#{Emoji.find_by_alias('mortar_board').raw} #{I18n.t('profile_state')}</b>
          \n  <a href='#{user.avatar_url}'>#{user.first_name} #{user.last_name}</a>
          \n  #{Emoji.find_by_alias('school').raw} #{I18n.t('average_score_percent')}: #{profile.average_score_percent}%
          \n  #{Emoji.find_by_alias('hourglass').raw} #{I18n.t('total_time_spent')}: #{profile.total_time_spent / 3600} #{I18n.t('hour')}
          \n  #{Emoji.find_by_alias('green_book').raw} #{I18n.t('courses')}: 
          #{I18n.t('active_courses')}: #{profile.active_courses_count} 
          #{I18n.t('archived_courses')}: #{profile.archived_courses_count}"
        end

        def course_list_l1
          menu.course_sessions_choice
        end

        def match_data

          on %r{archived_courses} do
            course_sessions_list(:archived)
          end

          on %r{active_courses} do
            course_sessions_list(:active)
          end

          on %r{update_course_sessions} do
            update_course_sessions
          end

          on %r{^cs_info_id:} do
            @message_value =~ %r{^cs_info_id:(\d*)}
            course_session_show_info($1)
          end

          on %r{^cs_id:} do
            @message_value =~ %r{^cs_id:(\d*)}
            sections_show($1)
          end
        end

      end
    end
  end
end