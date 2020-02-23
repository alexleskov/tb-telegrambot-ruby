module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class News
            SOURCE = "news".freeze

            include Teachbase::API::ParamChecker
            include Teachbase::API::MethodCaller

            attr_reader :url_ids, :request_options

            def initialize(url_ids, request_options)
              @url_ids = url_ids
              @request_options = request_options
            end

            def news
              if url_ids
                check!(:ids, [:id], url_ids)
                "#{SOURCE}/#{url_ids[:id]}"
              else
                SOURCE.to_s
              end
            end

            def news_like
              check!(:ids, [:id], url_ids)
              "#{news}/like"
            end
          end
        end
      end
    end
  end
end
