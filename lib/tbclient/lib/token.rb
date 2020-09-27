# frozen_string_literal: true

module Teachbase
  module API
    class Token
      class << self
        attr_reader :grant_types
      end

      @grant_types = { endpoint: "client_credentials", mobile: "password" }

      attr_reader :grant_type,
                  :expired_at,
                  :api_type,
                  :api_version,
                  :value,
                  :account_id,
                  :type,
                  :expires_in,
                  :refresh_token,
                  :created_at,
                  :resource_owner_id,
                  :expiration_time

      def initialize(api_type, api_version, params)
        @api_type = api_type
        @api_version = api_version
        @account_id = params[:account_id]
        @expiration_time = params[:expiration_time] || $app_config.token_expiration_time
        @params = params
        @grant_type = self.class.grant_types[api_type]
        @value = call_token
        raise "API token '#{value}' is null" unless value
      end

      def call_token
        @params[:access_token] ? @params[:access_token].to_s : token_request
      end

      def token_request
        r = @params[:rest_client].post "#{@params[:lms_host]}/oauth/token", create_payload.to_json,
                                       content_type: :json
        raw_token_response = JSON.parse(r.body)
        @expired_at = access_token_expired_at(raw_token_response)
        @type = raw_token_response["token_type"]
        @expires_in = raw_token_response["expires_in"]
        @refresh_token = raw_token_response["refresh_token"]
        @created_at = raw_token_response["created_at"]
        @resource_owner_id = raw_token_response["resource_owner_id"]
        raw_token_response["access_token"]
      rescue @params[:rest_client]::ExceptionWithResponse => e
        case e.http_code
        when 301, 302, 307
          e.response.follow_redirection
        else
          raise "Unexpected error with token requesting: Code: #{e.http_code}. Response: #{e.response}"
        end
      end

      protected

      def mobile_type?
        api_type == :mobile
      end

      def create_payload
        payload = { client_id: @params[:client_id],
                    client_secret: @params[:client_secret],
                    grant_type: grant_type }
        if mobile_type?
          payload.merge!(username: @params[:user_login],
                         password: @params[:password])
        end
        payload
      end

      def access_token_expired_at(raw_token_response)
        token_exp_time = @expiration_time.to_i
        raise "Token time limit = '#{token_exp_time}'. It can't be < 0." if token_exp_time.negative?

        Time.at(raw_token_response["created_at"]).utc + token_exp_time
      end
    end
  end
end
