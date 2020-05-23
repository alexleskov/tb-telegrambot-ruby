# frozen_string_literal: true

module Teachbase
  module API
    class Request
      SPLIT_SYMBOL = "_"
      URL_ID_PARAMS_FORMAT = /(^id|_id$)/.freeze
      DEFAULT_PAYLOAD_TYPE = :json

      attr_reader :lms_host,
                  :api_type,
                  :api_version,
                  :api_class,
                  :method_name,
                  :request_options,
                  :url_ids,
                  :url_params,
                  :payload,
                  :request_url,
                  :account_id,
                  :rest_client,
                  :answer_type

      def initialize(type_class_name, method_name, request_options = {}, token)
        @type_class_name = type_class_name
        @method_name = method_name
        @token = token
        @api_type = token.api_type
        @api_version = token.api_version
        @account_id = token.account_id
        @request_options = request_options
        @lms_host = request_options[:lms_host]
        @rest_client = request_options[:rest_client]
        @answer_type = request_options[:answer_type]
        @payload = request_options[:payload] || {}
        find_api_class
        create_request_data
      end

      def get
        push_request do
          rest_client.get(request_url, params: url_params, "X-Account-Id" => account_id.to_s)
        end
      end

      def delete
        push_request do
          rest_client.delete(request_url, params: url_params, "X-Account-Id" => account_id.to_s)
        end
      end

      def post
        push_request do
          rest_client.post(request_url, payload.to_json,
                           content_type: DEFAULT_PAYLOAD_TYPE,
                           "X-Account-Id" => account_id.to_s,
                           "Authorization" => "Bearer #{@token.value}")
        end
      end

      def patch
        push_request do
          rest_client.patch(request_url, payload.to_json,
                            content_type: DEFAULT_PAYLOAD_TYPE,
                            "X-Account-Id" => account_id.to_s,
                            "Authorization" => "Bearer #{@token.value}")
        end
      end

      private

      def push_request
        begin
          response = yield
        rescue rest_client::ExceptionWithResponse => e
          case e.http_code
          when 301, 302, 307
            e.response.follow_redirection
          else
            raise
          end
        end
        show_answer(response, answer_type)
      end

      def show_answer(response, type)
        case type
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
        find_api_version_class
        @api_class = Kernel.const_get("#{find_api_version_class}::#{camelize(@type_class_name)}")
      end

      def find_api_version_class
        @api_version_class = Kernel.const_get("Teachbase::API::Types::#{camelize(api_type)}::V#{api_version}")
      end

      def fetch_ids_for_url
        return if request_options.empty?

        ids_hash = request_options.select { |param| param =~ URL_ID_PARAMS_FORMAT && param != :account_id }
        ids_hash.empty? ? nil : ids_hash
      end

      def fetch_request_params
        default_url_params = access_token
        sanitize_not_request_params
        url_ids&.each { |key, _value| request_options.delete(key) }
        default_url_params.merge!(request_options)
      end

      def create_request_url
        method_path = api_class.call(method_name, url_ids, request_options)
        api_version_path = @api_version_class::VERSION_PATH
        raise "Can't find host and path url" if [lms_host, method_path, api_version_path].any?(nil)

        lms_host + api_version_path + method_path
      end

      def access_token
        { "access_token" => @token.value }
      end

      def sanitize_not_request_params
        %i[method payload api_version lms_host answer_type rest_client].each { |option| request_options.delete(option) }
      end

      def camelize(data)
        data.to_s.split(SPLIT_SYMBOL).collect(&:capitalize).join
      end
    end
  end
end
