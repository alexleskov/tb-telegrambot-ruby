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

          def courses_list_by(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0)
            return courses_update if state.to_sym == :update

            course_sessions = appshell.data_loader.cs.list(state: state, category: appshell.settings.scenario)    
            return interface.sys.text.on_empty.show if course_sessions.empty?

            interface.cs.menu(title_params: { text: course_sessions.first.sign_course_state },
                              object_type: :cs, path: :list, param: state,
                              back_button: { mode: :custom, action: router.cs(path: :list, p: [type: :states]).link })
                        .main(course_sessions, limit: limit.to_i, offset: offset.to_i).show
          end

          def courses_update
            check_status(:default) { appshell.data_loader.cs.update_all_states }
          end
        end
      end
    end
  end
end
