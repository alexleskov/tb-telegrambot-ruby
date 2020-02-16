require "json"
require "rest-client"

module Teachbase
  module API
    class Token
      TOKEN_TIME_LIMIT = 7200

      class << self
        attr_reader :versions
      end

      @versions = { endpoint_v1: "client_credentials",
                    mobile_v1: "password",
                    mobile_v2: "password" }.freeze

      attr_reader :grant_type, :expired_at, :version, :value

      def initialize(version, oauth_params)
        @version = version
        @oauth_params = oauth_params
        @grant_type = self.class.versions[version]
        load_token
      end

      def load_token
        if @oauth_params[:access_token]
          @value = @oauth_params[:access_token].to_s
        else
          @value = token_request
          raise "API token '#{value}' is null" if value.nil?
        end
      end

      def token_request
        r = RestClient.post "#{Teachbase::API::Client::LMS_HOST}/oauth/token", create_payload.to_json,
                            content_type: :json
        raw_token_response = JSON.parse(r.body)
        @expired_at = access_token_expired_at(raw_token_response)
        raw_token_response["access_token"]
      rescue RestClient::ExceptionWithResponse => e
        case e.http_code
        when 301, 302, 307
          e.response.follow_redirection
        else
          raise
        end
      end

      protected

      def mobile_version?
        %i[mobile_v1 mobile_v2].include? self.class.versions.key(grant_type)
      end

      def oauth_mobile_param?
        !([@oauth_params[:user_login], @oauth_params[:password]].any? { |key| key.nil? || key.empty? })
      end

      def create_payload
        payload = { "client_id" => @oauth_params[:client_id],
                    "client_secret" => @oauth_params[:client_secret],
                    "grant_type" => grant_type }
        if mobile_version? && oauth_mobile_param?
          payload.merge!("username" => @oauth_params[:user_login],
                         "password" => @oauth_params[:password])
        elsif mobile_version? && !oauth_mobile_param?
          raise "Not correct oauth params for Mobile API version token request."
        end
        payload
      end

      def access_token_expired_at(raw_token_response)
        token_limit = @oauth_params[:token_time_limit]
        raise "Token time limit = '#{token_limit}'. It can't be < 0." if token_limit.negative?

        Time.at(raw_token_response["created_at"]).utc + token_limit
      end
    end
  end
end
