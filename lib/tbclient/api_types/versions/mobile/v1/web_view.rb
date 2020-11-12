module Teachbase
  module API
    module Types
      module Mobile
        module V1
          class WebView
            SOURCE = "web_view".freeze

            def token
              "#{SOURCE}/token"
            end
          end
        end
      end
    end
  end
end
