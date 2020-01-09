require './lib/tbclient/client'

require 'active_record'

module Teachbase
  module Bot
    class AuthSession < ActiveRecord::Base
      belongs_to :user
      belongs_to :tg_account
      belongs_to :api_token

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

      #def load_material
      #  
      #end

    end
  end
end
