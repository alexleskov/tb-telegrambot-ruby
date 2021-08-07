# frozen_string_literal: true

require "rest-client"
require "json"

require './lib/app_configurator'
require './lib/tbclient/lib/token'
require './lib/tbclient/lib/request'
require './lib/tbclient/api_types/types'

module Teachbase
  module API
    class Client
      DEFAULT_ANSWER_TYPE = :json
      API_TYPES = { endpoint: "client_credentials", mobile: "password", refresh_token: "refresh_token" }
      API_VERSIONS = { endpoint: [1], mobile: [1, 2], refresh_token: [1, 2] }

      attr_reader :api_type, :api_version, :lms_host, :token, :client_id, :account_id, :rest_client, :grant_type, :answer_type

      def initialize(api_type, version_number, client_params = {})
        @api_type = api_type
        @api_version = version_number
        @rest_client = client_params[:rest_client] ||= Kernel.const_get($app_config.rest_client)
        @grant_type = API_TYPES[api_type]
        raise "No such API type: '#{api_type}'. Use one of: #{API_TYPES.keys}" unless grant_type
        raise "No such API version: '#{api_version}'. Use one of #{API_VERSIONS}" unless API_VERSIONS[api_type].include?(api_version)

        @lms_host = client_params[:lms_host] ||= $app_config.lms_host
        @account_id = client_params[:account_id]
        @client_id = client_params[:client_id]
        @client_secret = client_params[:client_secret]
        @refresh_token = client_params[:refresh_token]
        @access_token = client_params[:access_token]
        @user_login = client_params[:user_login]
        @password = client_params[:password]
        @auth_code = client_params[:auth_code]
        @answer_type = client_params[:answer_type]
        raise "Not correct auth params. For api type: '#{api_type}'" unless auth_param?

        @config = build_config
        call_token
      end

      def call_token
        @token = Teachbase::API::Token.new(@config).call
      end

      def request(type_class_name, api_method_name, request_options = {})
        raise "Can't find config for requesting" unless @config
        raise "Can't find token for requesting" unless token

        Teachbase::API::Request.new(type_class_name, api_method_name, @config, token, request_options)
      end

      def auth_param?
        return @access_token if @access_token

        auth_params_list =
        case api_type.to_sym
        when :endpoint
          client_params_list
        when :mobile
          mobile_params_list
        when :refresh_token
          refresh_token_params_list
        end
        auth_params_list.none?(nil)
      end

      private

      def build_config
        OpenStruct.new(api_type: @api_type, api_version: @api_version, rest_client: @rest_client,
                       lms_host: @lms_host, client_id: @client_id, client_secret: @client_secret,
                       account_id: @account_id, access_token: @access_token, refresh_token: @refresh_token,
                       grant_type: @grant_type, auth_code: @auth_code, user_login: @user_login, password: @password,
                       answer_type: DEFAULT_ANSWER_TYPE || @answer_type)
      end

      def client_params_list
        [@client_id, @client_secret, @account_id]
      end

      def mobile_params_list
        client_params_list + [@user_login, @password]
      end

      def refresh_token_params_list
        client_params_list + [@refresh_token]
      end
    end
  end
end