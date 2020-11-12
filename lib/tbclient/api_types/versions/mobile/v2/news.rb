module Teachbase
  module API
    module Types
      module Mobile
        module V2
          class News < MethodEntity
            SOURCE = "news".freeze

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
