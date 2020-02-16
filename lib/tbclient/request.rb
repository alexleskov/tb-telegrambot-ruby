require './lib/tbclient/endpoints/endpoints_version'

module Teachbase
  module API
    class Request
      SPLIT_SYMBOL = "_".freeze
      URL_ID_PARAMS_FORMAT = /(^id|_id$)/.freeze

      attr_reader :response,
                  :client,
                  :method_name,
                  :request_url,
                  :request_params,
                  :url_ids,
                  :account_id,
                  :http_method,
                  :payload

      def initialize(method_name, client, params = {})
        @method_name = method_name.to_s
        @method_array = method_name_to_array
        @client = client
        @params = params
        @http_method = params[:method] || :get
        @payload = params[:body]
        @request_params = {}
        create_request_data
      end

      def receive_response(endpoint_response)
        @response = endpoint_response
      end

      protected

      def create_request_data
        @endpoint_class = find_endpoint_class
        endpoint_method = change_split_symbol(find_endpoint_method, /-/, SPLIT_SYMBOL)

        endpoint = Kernel.const_get("Teachbase::API::EndpointsVersion::#{fetch_endpoint_version}::#{@endpoint_class}").new(self)
        raise "No instance method '#{endpoint_method}' in '#{endpoint}'" unless endpoint.respond_to? endpoint_method

        fetch_request_headers
        @url_ids = fetch_ids_for_url
        @request_params = fetch_request_params
        @request_params["access_token"] = client.token.value
        @request_url = create_request_url
        endpoint.public_send(endpoint_method)
      end

      def fetch_endpoint_version
        client.token.version.to_s.split(SPLIT_SYMBOL).collect(&:capitalize).join
      end

      def find_endpoint_class
        endpoints_list = Teachbase::API::EndpointsVersion::LIST
        endpoint_alias = @method_array.shift
        raise "'#{endpoint_alias}' no such endpoint alias. Avaliable " unless endpoints_list.key?(endpoint_alias)

        @endpoint_class = endpoints_list[endpoint_alias]
      end

      def find_endpoint_method
        endpoint_method = @method_array.join(SPLIT_SYMBOL)
        endpoint_method.empty? ? convert_endpoint_class_to_method : endpoint_method
      end

      def method_name_to_array
        method_name.split(SPLIT_SYMBOL)
      end

      def change_split_symbol(string, from, to)
        result = string.gsub(from, to)
        result.nil? ? string : result
      end

      def convert_endpoint_class_to_method
        change_split_symbol(method_name, /-/, SPLIT_SYMBOL)
      end

      def fetch_ids_for_url
        return if @params.empty?

        url_ids = @params.select { |param| param =~ URL_ID_PARAMS_FORMAT && param != :account_id }
        url_ids.empty? ? nil : url_ids
      end

      def fetch_request_headers
        @account_id = @params[:account_id] || client.account_id
      end

      def fetch_request_params
        sanitize_not_request_params(@params)
        url_ids&.each { |key, _value| @params.delete(key) }
        @request_params.merge!(@params)
      end

      def sanitize_not_request_params(req_params)
        %i[method body].each { |option| req_params.delete(option) }
      end

      def create_request_url
        host = client.api_version
        path = method_name_to_array
        raise "Can't find host and path url" if [host, path].any?(nil)
        
        path_url = if @url_ids.nil?
                     path.join("/")
                   else
                     path_with_ids = []
                     path.each_with_index do |item, ind|
                       path_with_ids << item
                       path_with_ids.rotate
                       path_with_ids << @url_ids.values[ind]
                     end
                     path_with_ids.join("/")
                   end

        host + change_split_symbol(path_url, /-/, SPLIT_SYMBOL)
      end
    end
  end
end
