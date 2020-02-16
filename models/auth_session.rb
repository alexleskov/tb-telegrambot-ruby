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

      def load_course_sessions(state)
        tb_api.request("course-sessions", order_by: "progress", order_direction: "asc", filter: state.to_s).response.answer
      end

      def load_cs_info(course_session_id)
        tb_api.request("course-sessions", id: course_session_id).response.answer
      end

      def load_material(course_session_id, material_id)
        tb_api.request("course-sessions_materials", cs_id: course_session_id, m_id: material_id).response.answer
      end
    end
  end
end
