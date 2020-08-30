module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class Tasks
            SOURCE = "course_sessions".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def course_sessions_tasks
              check!(:ids, %i[session_id id], url_ids)
              "#{SOURCE}/#{url_ids[:session_id]}/tasks/#{url_ids[:id]}"
            end

            def course_sessions_tasks_task_answers
              "#{course_sessions_tasks}/task_answers"
            end

            def task_answers_comments
              check!(:ids, %i[id], url_ids)
              "task_answers/#{url_ids[:id]}/comments"
            end
          end
        end
      end
    end
  end
end
