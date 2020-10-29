# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Content < Teachbase::Bot::InterfaceController
        
        attr_accessor :link, :link_name, :file

        def initialize(params, entity)
          @link = params[:link]
          @link_name = params[:link_name]
          @file = params[:file]
          super(params, entity)
        end

        def photo
          answer.content.photo(file)
        end

        def video
          answer.content.video(file)
        end

        def document
          answer.content.document(file)
        end

        def audio
          answer.content.audio(file)
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