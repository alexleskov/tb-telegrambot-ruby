# frozen_string_literal: true

  class EditorJs
    class Block
      class Image < EditorJs::Block::External
        attr_reader :url

        def initialize(data)
          @url = "#{EditorJs::HOST}#{data["file"]["url"]}"
          super(data)
        end

        def render
          "#{EmojiAliaser.image} <a href='#{build_url}'>#{name}</a>"
        end

        private

        def build_name
          caption.empty? ? parse_file_name(:only_name) : caption
        end
      end
    end
  end