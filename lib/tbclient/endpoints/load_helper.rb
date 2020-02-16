module Teachbase
  module API
    module LoadHelper
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods; end

      attr_reader :request

      def send_request(option = :normal, params = {})
        request_has_ids?(params[:ids_count]) if option == :with_ids
        if %i[post patch].include?(request.http_method) && request.payload.nil?
          raise "Empty body: #{request.payload} for http method: '#{request.http_method}'"
        end

        begin
          push_request
          @answer_json = JSON.parse(@r.body)
          request.receive_response(self)
        rescue RestClient::ExceptionWithResponse => e
          case e.http_code
          when 301, 302, 307
            e.response.follow_redirection
          else
            raise
          end
        end
      end

      def answer(type = :raw)
        case type
        when :raw
          @answer_json
        when :object
          OpenStruct.new(@answer_json)
        else
          raise "No such param for getting response answer. Aval: ':raw', ':object'"
        end
      end

      private

      def push_request
        @r = case request.http_method
             when :get
               RestClient.get request.request_url, params: request.request_params,
                                                   "X-Account-Id" => request.account_id.to_s
             when :post
               RestClient.post request.request_url, request.payload.merge!(request.request_params).to_json,
                               "X-Account-Id" => request.account_id.to_s,
                               content_type: :json
             when :patch
               RestClient.patch request.request_url, request.payload.merge!(request.request_params).to_json,
                                "X-Account-Id" => request.account_id.to_s,
                                content_type: :json
             when :delete
               RestClient.delete request.request_url, params: request.request_params,
                                                      "X-Account-Id" => request.account_id.to_s
             else
               raise "Can't find such http method: #{request.http_method}"
             end
      end

      def request_has_ids?(ids_count)
        raise "Must set 'ids_count' if using mode ':with_ids" unless ids_count
        raise "Must have '#{ids_count} id' for '#{request.method_name}' method" unless request.url_ids.size == ids_count
      end
    end
  end
end
