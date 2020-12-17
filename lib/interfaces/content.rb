# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Content < Teachbase::Bot::InterfaceController
        attr_reader :link, :link_name, :file, :caption

        def initialize(params, entity)
          @link = params[:link]
          @link_name = params[:link_name]
          @file = params[:file]
          @caption = params[:caption]
          super(params, entity)
        end

        def photo
          answer.content.photo(photo: file, caption: caption)
        end

        def video
          answer.content.video(video: file, caption: caption)
        end

        def document
          answer.content.document(document: file, caption: caption)
        end

        def audio
          answer.content.audio(audio: file, caption: caption)
        end

        def url
          answer.content.url(link: link, link_name: link_name)
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
