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
            category ||= appshell.settings.scenario
            cs_loader = appshell.data_loader.cs
            total_cs_count = cs_loader.total_cs_count(state: state, category: category)
            # TO DO: Change after fix on Teachbase with course_sessions list sorting
            # per_page = limit
            # page = (offset.to_f / per_page.to_f).ceil
            page = offset.zero? ? 1 : (offset.to_f / 100.to_f).ceil
            per_page = page * 100
            course_sessions = cs_loader.list(state: state, category: category, limit: limit,
                                             offset: offset, per_page: per_page, page: page)
            return interface.sys.text.on_empty.show if course_sessions.empty?

            interface.cs.menu(title_params: { text: course_sessions.first.sign_course_state },
                              path_params: { object_type: :cs, path: :list, param: state },
                              back_button: { mode: :custom, action: router.cs(path: :list, p: [type: :states]).link })
                     .main(course_sessions, limit: limit, offset: offset, all_count: total_cs_count).show
          end

          def courses_update(mode = :none)
            check_status(:default) { appshell.data_loader.cs.update_all_states(mode: mode) }
          end
        end
      end
    end
  end
end
