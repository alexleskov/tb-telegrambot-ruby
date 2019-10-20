require 'active_record'
require './models/api_token'
require './models/course_session'
require './lib/tbclient/client'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      has_many :api_tokens, dependent: :destroy
      attr_reader :tb_api

      def api_auth(version, oauth_params = {})
        @tb_api = Teachbase::API::Client.new(version, oauth_params)
      end

      def load_profile
        tb_api.request("profile").response.answer
      end

      def load_active_course_sessions
        tb_api.request("course-sessions", order_by: "progress", order_direction: "asc", filter: "active").response.answer
      end

      def load_archived_course_sessions
        tb_api.request("course-sessions", order_by: "progress", order_direction: "asc", filter: "archived").response.answer
      end

      def load_sections(course_session_id)
        tb_api.request("course-sessions_/", id: course_session_id).response.answer
      end
    end
  end
end
