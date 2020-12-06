# frozen_string_literal: true

require './lib/tbclient/client'

require 'active_record'

module Teachbase
  module Bot
    class AuthSession < ActiveRecord::Base
      belongs_to :user
      belongs_to :tg_account
      belongs_to :api_token
      belongs_to :account

      class << self
        def active_auth_sessions_by(user_tb_id)
          joins('LEFT JOIN users ON auth_sessions.user_id = users.id')
            .where("users.tb_id = :user_tb_id AND auth_sessions.active IS TRUE", user_tb_id: user_tb_id.to_i)
            .order(auth_at: :desc)
        end
      end

      attr_reader :tb_api

      def activate_by(user_id, apitoken_id)
        update!(auth_at: Time.now.utc,
                active: true,
                api_token_id: apitoken_id,
                user_id: user_id)
      end

      def api_auth(api_type, version, oauth_params = {})
        @tb_api = Teachbase::API::Client.new(api_type, version, oauth_params)
      end

      def load_profile
        tb_api.request(:user, :profile).get
      end

      def load_user_accounts
        tb_api.request(:user, :accounts).get
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

      def load_poll(cs_id, poll_id)
        tb_api.request(:polls, :course_sessions_polls, course_session_id: cs_id, id: poll_id).get
      end

      def load_documents
        tb_api.request(:documents, :documents).get
      end

      def load_course_types
        tb_api.request(:course_types, :course_types).get
      end

      def send_task_answer(cs_id, task_id, answer)
        raise "Answer must be a Hash" unless answer.is_a?(Hash)
        return if answer[:text].empty? && answer[:attachments].empty?

        tb_api.request(:tasks, :course_sessions_tasks_task_answers, session_id: cs_id, id: task_id,
                                                                    payload: answer, content_type: "multipart/form-data").post
      end

      def send_task_comment(task_stat_id, comment)
        raise "Comment must be a Hash" unless comment.is_a?(Hash)
        return if comment[:text].empty? && comment[:attachments].empty?

        tb_api.request(:tasks, :task_answers_comments, id: task_stat_id, payload: comment).post
      end

      def track_time(cs_id, material_id, time_spent)
        tb_api.request(:course_sessions, :course_sessions_materials_track, session_id: cs_id,
                                                                           id: material_id, payload: { time_spent: time_spent }).post
      end

      def add_user_to_account(user_data, labels)
        tb_api.request(:users, :users_create, payload: build_user_registration_data(user_data, labels)).post
      end

      private

      def build_user_registration_data(user_data, labels)
        payload_data = { "users" => [
          { "name" => user_data.first_name,
            "last_name" => user_data.last_name,
            "phone" => user_data.phone,
            "role_id" => 1,
            "auth_type" => 0,
            "password" => user_data.password.decrypt(:symmetric, password: $app_config.load_encrypt_key),
            "lang" => "ru" }
        ],
                         "options" => { "activate" => true, "skip_notify_new_users" => true, "skip_notify_active_users" => true } }
        raise unless labels.is_a?(Hash)

        labels.empty? ? payload_data : payload_data["users"][0]["labels"] = labels
        payload_data
      end
    end
  end
end
