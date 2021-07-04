# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Content < Teachbase::Bot::InterfaceController
        def photo
          answer.content.photo(params).push
        end

        def video
          answer.content.video(params).push
        end

        def document
          answer.content.document(params).push
        end

        def audio
          answer.content.audio(params).push
        end

        def url
          answer.content.url(params).push
        end

        def iframe
          url
        end

        def youtube
          iframe
        end

        def pdf
          document
        end
      end
    end
  end
end
