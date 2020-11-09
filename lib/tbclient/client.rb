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
      API_TYPES = %i[endpoint mobile].freeze
      API_VERSIONS = [1, 2].freeze
      DEFAULT_ANSWER_TYPE = :json

      attr_reader :api_type, :api_version, :lms_host, :response, :token

      def initialize(api_type, version_number, client_params = {})
        @api_type = api_type
        @api_version = version_number
        @rest_client = client_params[:rest_client] ||= Kernel.const_get($app_config.rest_client)
        @lms_host = client_params[:lms_host] ||= $app_config.lms_host
        @client_params = client_params

        raise "No such API type: '#{api_type}'. Use one of: #{API_TYPES}" unless %i[endpoint mobile].include?(api_type.to_sym)
        raise "No such API destination. Type: #{api_type}, version: #{api_version}" unless api_version_and_type_exists?(api_type, api_version)
        raise "Set up: 'client_id' and 'client_secret'. Your params: #{client_params}" if !api_mobile_type? && !auth_param?
        raise "Set up: 'user_login', 'password', 'account_id'. Your params: #{client_params}" if api_mobile_type? && !auth_param?

        @token = Teachbase::API::Token.new(api_type, api_version, client_params)
      end

      def request(type_class_name, api_method_name, options = {})
        options[:lms_host] = lms_host
        options[:rest_client] = @rest_client
        options[:answer_type] ||= DEFAULT_ANSWER_TYPE
        Teachbase::API::Request.new(type_class_name, api_method_name, options, token)
      end

      private

      def api_mobile_type?
        api_type == :mobile
      end

      def auth_param?
        auth_params_list = api_mobile_type? ? mobile_params_list : client_params_list
        @client_params[:access_token] || auth_params_list.none?(nil)
      end

      def client_params_list
        [@client_params[:client_id], @client_params[:client_secret], @client_params[:account_id]]
      end

      def mobile_params_list
        client_params_list + [@client_params[:user_login], @client_params[:password]]
      end

      def api_version_and_type_exists?(api_type, api_version)
        case api_type
        when :endpoint
          api_version == API_VERSIONS.first
        when :mobile
          API_VERSIONS.include?(api_version)
        end
      end
    end
  end
end
