# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module CourseSession
          DEFAULT_COUNT_PAGINAION = 15

          def courses_states
            interface.cs.menu(text: "#{Emoji.t(:books)}<b>#{I18n.t('show_course_list')}</b>").states
          end

          alias cs_list courses_states

          def courses_list_by(state, limit = DEFAULT_COUNT_PAGINAION, offset = 0)
            return courses_update if state.to_sym == :update

            interface.sys.destroy(delete_bot_message: { mode: :last, type: :reply_markup })
            offset = offset.to_i
            limit = limit.to_i
            course_sessions = appshell.data_loader.cs.list(state: state, category: appshell.settings.scenario)
            return interface.sys.text.on_empty if course_sessions.empty?

            interface.cs.menu(text: course_sessions.first.sign_course_state)
                     .main(course_sessions.limit(limit).offset(offset))
            offset += limit
            return if offset >= course_sessions.size

            interface.sys.menu(object_type: :cs, path: :list, all_count: course_sessions.size, param: state,
                               limit_count: limit, offset_num: offset).show_more
          end

          def courses_update
            check_status(:default) { appshell.data_loader.cs.update_all_states }
          end
        end
      end
    end
  end
end
