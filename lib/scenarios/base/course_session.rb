# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module CourseSession
          DEFAULT_COUNT_PAGINAION = 5

          def courses_states
            interface.cs.menu.states.show
          end

          alias cs_list courses_states
          alias studying courses_states

          def courses_list_by(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0, category = nil)
            return courses_update(:with_reload) if state.to_sym == :update

            limit = limit.to_i
            offset = offset.to_i
            category ||= appshell.user_settings.scenario
            cs_loader = appshell.data_loader.cs(state: state, category: category)
            total_cs_count = cs_loader.total_cs_count
            per_page = limit
            page = (offset / per_page) + 1
            course_sessions = cs_loader.list(limit: limit, offset: offset, per_page: per_page, page: page)
            return interface.sys.text.on_empty.show if course_sessions.empty?

            interface.cs.menu(title_params: { text: course_sessions.first.sign_course_state },
                              path_params: { object_type: :cs, path: :list, param: state },
                              back_button: { mode: :custom, action: router.cs(path: :list).link })
                     .main(course_sessions, limit: limit, offset: offset, all_count: total_cs_count).show
          end

          def courses_update(mode = :none)
            check_status(:default) { appshell.data_loader.cs.update_all_states(mode: mode) }
          end

          def course_by(cs_tb_id)
            course_session = appshell.data_loader.cs(tb_id: cs_tb_id).info
            user_name = appshell.user_fullname(:array).first
            interface.cs(course_session).text(text: "#{I18n.t('greeting_message')} #{user_name}!\n\n#{I18n.t('notify_about_new')} #{I18n.t('course').downcase}:")
                     .course.show
          end
        end
      end
    end
  end
end
