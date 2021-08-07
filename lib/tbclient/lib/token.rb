# frozen_string_literal: true

module Teachbase
  module API
    class Token
      attr_reader :expired_at,
                  :value,
                  :type,
                  :expires_in,
                  :refresh_token,
                  :created_at,
                  :resource_owner_id,
                  :api_version,
                  :api_type,
                  :grant_type

      def initialize(client_config)
        @client_config = client_config
        @api_version = client_config.api_version
        @api_type = client_config.api_type
        @grant_type = client_config.grant_type
      end

      def call
        @value = @client_config.access_token ? @client_config.access_token.to_s : request
        raise "API token '#{value}' is null" unless value

        self
      end

      private

      def request
        r = @client_config.rest_client.post("#{@client_config.lms_host}/oauth/token", create_payload.to_json,
                                            content_type: @client_config.answer_type)
        raw_token_response = JSON.parse(r.body)
        @expired_at = define_expired_at(raw_token_response["created_at"])
        @type = raw_token_response["token_type"]
        @expires_in = raw_token_response["expires_in"]
        @refresh_token = raw_token_response["refresh_token"]
        @created_at = raw_token_response["created_at"]
        @resource_owner_id = raw_token_response["resource_owner_id"]
        @value = raw_token_response["access_token"]
      rescue @client_config.rest_client::ExceptionWithResponse => e
        case e.http_code
        when 301, 302, 307
          e.response.follow_redirection
        else
          raise e, "Unexpected error with token requesting: Code: #{e.http_code}. Response: #{e.response}"
        end
      end

      def create_payload
        { client_id: @client_config.client_id, client_secret: @client_config.client_secret, grant_type: @client_config.grant_type,
          username: @client_config.user_login, password: @client_config.password, auth_code: @client_config.auth_code,
          refresh_token: @client_config.refresh_token }
      end

      def define_expired_at(token_created_at)
        raise "Can't find token created at time" unless token_created_at

        token_exp_time = $app_config.token_expiration_time.to_i
        raise "Token time limit = '#{token_exp_time}'. It can't be < 0." if token_exp_time.negative?

        Time.at(token_created_at).utc + token_exp_time
      end
    end
  end
end
