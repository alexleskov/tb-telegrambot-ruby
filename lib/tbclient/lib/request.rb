# frozen_string_literal: true

module Teachbase
  module API
    class Request
      class << self
        def auth_code(user_login, client_config)
          auth_code_request = new(:code, :one_time_code, client_config, "", login: user_login, answer_type: :raw)
          auth_code_request.post
        end
      end

      SPLIT_SYMBOL = "_"
      URL_ID_PARAMS_FORMAT = /(^id|_id$)/.freeze
      DEFAULT_PAYLOAD_TYPE = :json

      attr_reader :api_class,
                  :method_name,
                  :request_options,
                  :url_ids,
                  :url_params,
                  :payload,
                  :request_url,
                  :content_type,
                  :headers,
                  :answer_type

      def initialize(type_class_name, method_name, client_config, token, request_options = {})
        @client_config = client_config
        @type_class_name = type_class_name
        @method_name = method_name
        @token = token
        @request_options = request_options
        @content_type = DEFAULT_PAYLOAD_TYPE
        @payload = request_options[:payload] || {}
        @answer_type = request_options[:answer_type] || @client_config.answer_type
        @headers = set_headers
        create_request_data
      end

      def get
        push_request do
          @client_config.rest_client.get(request_url, default_settings(:get))
        end
      end

      def delete
        push_request do
          @client_config.rest_client.delete(request_url, default_settings(:delete))
        end
      end

      def post
        push_request do
          @client_config.rest_client.post(request_url, payload, default_settings(:post))
        end
      end

      def patch
        push_request do
          @client_config.rest_client.patch(request_url, payload, default_settings(:patch))
        end
      end

      private

      def set_headers
        request_options[:headers] ? default_headers.merge!(request_options[:headers]) : default_headers
      end

      def default_settings(_http_method)
        { params: url_params }.merge!(headers)
      end

      def default_headers
        { content_type: content_type,
          "X-Account-Id" => @client_config.account_id.to_s,
          "Authorization" => "Bearer #{@token.is_a?(Teachbase::API::Token) ? @token.value : ''}",
          "User-Agent" => "telegram-bot" }
      end

      def push_request
        begin
          response = yield
        rescue @client_config.rest_client::ExceptionWithResponse => e
          case e.http_code
          when 301, 302, 307
            e.response.follow_redirection
          else
            raise e
          end
        end
        show_answer(response)
      end

      def show_answer(response)
        case answer_type
        when :raw
          response
        when :json
          JSON.parse(response.body)
        when :object
          r = JSON.parse(response.body)
          if r.is_a?(Array)
            objects = []
            r.each { |object| objects << OpenStruct.new(object) }
            objects
          else
            OpenStruct.new(r)
          end
        else
          raise "No such param for getting response. Aval: ':raw', ':json', ':object'"
        end
      end

      def create_request_data
        @url_ids = fetch_ids_for_url
        @url_params = fetch_request_params
        @request_url = create_request_url
      end

      def find_api_class
        @api_class = Kernel.const_get("#{find_api_version_class}::#{camelize(@type_class_name)}")
      end

      def find_api_version_class
        Kernel.const_get("Teachbase::API::Types::#{camelize(@client_config.api_type)}::V#{@client_config.api_version}")
      end

      def fetch_ids_for_url
        return if request_options.empty?

        ids_hash = request_options.select { |param| param =~ URL_ID_PARAMS_FORMAT && param != :account_id }
        return if ids_hash.empty?

        ids_hash
      end

      def fetch_request_params
        default_url_params = @token.is_a?(Teachbase::API::Token) ? access_token : {}
        sanitize_not_request_params
        url_ids&.each { |key, _value| request_options.delete(key) }
        default_url_params.merge!(request_options)
      end

      def create_request_url
        method_path = find_api_class.call(method_name, url_ids, request_options)
        api_version_path = find_api_version_class::VERSION_PATH
        raise "Can't find host and path url" if [@client_config.lms_host, method_path, api_version_path].any?(nil)

        @client_config.lms_host + api_version_path + method_path
      end

      def access_token
        { "access_token" => @token.value }
      end

      def sanitize_not_request_params
        %i[method payload headers].each { |option| request_options.delete(option) }
      end

      def camelize(data)
        data.to_s.split(SPLIT_SYMBOL).collect(&:capitalize).join
      end
    end
  end
end
