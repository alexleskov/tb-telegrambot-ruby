# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Base
        class CourseSession < Teachbase::Bot::Strategies
          DEFAULT_COUNT_PAGINAION = 5

          def states
            interface.cs.menu(back_button: { mode: :custom, action: router.g(:main, :find, p: [type: :cs]).link,
                                             button_sign: I18n.t('search'), emoji: :mag, order: :ending }).states.show
          end

          def list_by(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0, category = nil)
            return check_status(:default) { update_all(:with_reload) } if state.to_sym == :update

            limit = limit.to_i
            offset = offset.to_i
            cs_loader = appshell.data_loader.cs(state: state, category: category)
            total_cs_count = cs_loader.total_cs_count
            per_page = limit
            page = (offset / per_page) + 1
            course_sessions = cs_loader.list(limit: limit, offset: offset, per_page: per_page, page: page)
            return interface.sys.text.on_empty.show if course_sessions.empty?

            interface.cs.menu(title_params: { text: course_sessions.first.sign_course_state },
                              route_params: { route: :cs, path: :list, param: state },
                              back_button: { mode: :custom, action: router.g(:cs, :list).link })
                     .list(course_sessions, limit: limit, offset: offset, all_count: total_cs_count).show
          end

          def update_all(mode = :none)
            appshell.data_loader.cs.update_all_states(mode: mode)
          end
        end
      end
    end
  end
end
