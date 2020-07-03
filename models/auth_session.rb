# frozen_string_literal: true

require './lib/tbclient/client'

require 'active_record'

module Teachbase
  module Bot
    class AuthSession < ActiveRecord::Base
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

      def load_course_sessions(state, options = {})
        tb_api.request(:course_sessions, :course_sessions, options.merge!(filter: state.to_s)).get
      end

      def load_cs_info(cs_id)
        tb_api.request(:course_sessions, :course_sessions, id: cs_id).get
      end

      def load_cs_progress(cs_id)
        tb_api.request(:course_sessions, :course_sessions_progress, id: cs_id).get
      end

      def load_material(cs_id, material_id)
        tb_api.request(:materials, :course_sessions_materials, session_id: cs_id, id: material_id).get
      end

      def load_task(cs_id, task_id)
        tb_api.request(:tasks, :course_sessions_tasks, session_id: cs_id, id: task_id).get
      end

      def load_scorm_package(cs_id, scorm_package_id)
        tb_api.request(:scorm_packages, :course_sessions_scorm_packages, course_session_id: cs_id, id: scorm_package_id).get
      end

      def load_quiz(cs_id, quiz_id)
        tb_api.request(:quiz, :course_sessions_quizzes, course_session_id: cs_id, id: quiz_id).get
      end

      def send_task_answer(cs_id, task_id, answer)
        raise "Answer must be a Hash" unless answer.is_a?(Hash)

        tb_api.request(:tasks, :course_sessions_tasks_task_answers, session_id: cs_id, id: task_id,
                                                                    payload: answer, content_type: "multipart/form-data").post
      end

      def track_material(cs_id, material_id, time_spent)
        tb_api.request(:course_sessions, :course_sessions_materials_track, session_id: cs_id,
                                                                           id: material_id, payload: { time_spent: time_spent }).post
      end
    end
  end
end
