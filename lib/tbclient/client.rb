require './lib/app_configurator'
require './lib/tbclient/token'
require './lib/tbclient/request'

module Teachbase
  module API
    class Client
      LMS_HOST = "https://go.teachbase.ru".freeze
      VERSIONS = { endpoint_v1: "#{LMS_HOST}/endpoint/v1/",
                   mobile_v1: "#{LMS_HOST}/mobile/v1/",
                   mobile_v2: "#{LMS_HOST}/mobile/v2/" }.freeze

      attr_reader :token, :api_version, :account_id

      def initialize(version, oauth_params = {})
        config = AppConfigurator.new
        @api_version = choose_version(version)
        @account_id ||= config.get_api_accountid
        oauth_params[:client_id] ||= config.get_api_client_id
        oauth_params[:client_secret] ||= config.get_api_client_secret
        oauth_params[:token_time_limit] ||= Teachbase::API::Token::TOKEN_TIME_LIMIT

        unless oauth_client_param?(oauth_params[:client_id], oauth_params[:client_secret])
          raise "Set up 'client_id' and 'client_secret'"
        end

        @token = Teachbase::API::Token.new(version, oauth_params)
      end

      def request(method_name, params = {})
        Teachbase::API::Request.new(method_name, self, params)
      end

      protected

      def oauth_client_param?(client_id, client_secret)
        !([client_id, client_secret].any? { |key| key.nil? || key.empty? })
      end

      def api_version_exists?(version)
       VERSIONS.key?(version.to_sym)
      end

      def choose_version(version)
        if api_version_exists?(version)
          VERSIONS[version.to_sym]
        else
          raise "API version '#{version}' not exists.\nAvaliable: #{VERSIONS.keys}"
        end
      end
    end
  end
end
