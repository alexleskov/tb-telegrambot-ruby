require './lib/tbclient/client'

require 'active_record'

module Teachbase
  module Bot
    class AuthSession < ActiveRecord::Base
      CONTENT_TYPES_CNAME = { quizzes: :quiz, scorm_packages: :scorms }

      belongs_to :user
      belongs_to :tg_account
      belongs_to :api_token

      attr_reader :tb_api

      def api_auth(api_type, version, oauth_params = {})
        @tb_api = Teachbase::API::Client.new(api_type, version, oauth_params)
      end

      def load_profile
        tb_api.request(:user, :profile).get
      end

      def load_course_sessions(state, options = { order_by: "progress", order_direction: "asc", page: 1, per_page: 100 })
        tb_api.request(:course_sessions, :course_sessions, options.merge!(filter: state.to_s)).get
      end

      def load_cs_info(cs_id)
        tb_api.request(:course_sessions, :course_sessions, id: cs_id).get
      end

      def load_content(type, cs_id, content_id)
        source_type = correct_content_type(type)
        tb_api.request(source_type, "course_sessions_#{type}".to_sym, session_id: cs_id, id: content_id).get
      end

      def load_material(cs_id, material_id)
        tb_api.request(:materials, :course_sessions_materials, session_id: cs_id, id: material_id).get
      end

      def load_task(cs_id, task_id)
        tb_api.request(:tasks, :course_sessions_tasks, session_id: cs_id, id: task_id).get
      end

      private

      def correct_content_type(type)
        content_type = CONTENT_TYPES_CNAME[type.to_sym]
        content_type ? content_type : type
      end

    end
  end
end
