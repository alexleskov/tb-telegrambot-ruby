require "json"
require "rest-client"
require './lib/tbclient/request_default_param'

module Teachbase
  module API
    module EndpointsVersion
      module MobileV2
        class CourseSession
          include RequestDefaultParam
          include Teachbase::API::LoadChecker
          include Teachbase::API::LoadHelper

          def initialize(request)
            raise "'#{request}' must be 'Teachbase::API::Request'" unless request.is_a?(Teachbase::API::Request)

            @request = request
          end

          def course_sessions
            check :ids, :filter
            check_and_apply_default_req_params
            send_request
          end

          def materials
            send_request :with_ids, ids_count: 2
          end

          def content
            send_request :with_ids, ids_count: 1
          end

          def complete
            send_request :with_ids, ids_count: 1, method: :post
          end

          def questions
            send_request :with_ids, ids_count: 2
          end

          def questions_submit
            send_request :with_ids, ids_count: 2, method: :post
          end

          def questions_track
            send_request :with_ids, ids_count: 2, method: :post
          end

          def quizzes_start
            send_request :with_ids, ids_count: 2, method: :post
          end

          def quizzes_results
            send_request :with_ids, ids_count: 2
          end

          def quiz_stats_check
            send_request :with_ids, ids_count: 2, method: :post
          end

          def quizzes
            send_request :with_ids, ids_count: 2
          end

          def scorm_packages
            send_request :with_ids, ids_count: 2
          end

          def tasks
            send_request :with_ids, ids_count: 2
          end
        end
      end
    end
  end
end
