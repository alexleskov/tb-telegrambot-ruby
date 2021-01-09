# frozen_string_literal: true

module Teachbase
  module Bot
    class Webhook
      class CourseStat < Teachbase::Bot::Webhook
        attr_reader :c_tb_id, :cs_tb_id, :user_tb_id

        def initialize(request)
          super
          raise "Can't find webhook's body data" unless webhook.payload

          @c_tb_id = webhook.payload["data"]["course_id"].to_i
          @cs_tb_id = webhook.payload["data"]["course_session_id"].to_i
          @user_tb_id = webhook.payload["data"]["user_id"].to_i
        end
      end
    end
  end
end
