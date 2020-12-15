# frozen_string_literal: true

module Teachbase
  module Bot
    class Webhook
      class CourseStat < Teachbase::Bot::Webhook
        attr_reader :c_tb_id, :cs_tb_id

        def initialize(request)
          super
          raise "Can't find request's body data" unless request_body

          @c_tb_id = request_body["course_id"]
          @cs_tb_id = request_body["course_session_id"]
        end
      end
    end
  end
end
