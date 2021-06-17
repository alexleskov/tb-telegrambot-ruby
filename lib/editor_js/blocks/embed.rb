# frozen_string_literal: true

  class EditorJs
    class Block
      class Embed < EditorJs::Block::External
        attr_reader :url

        def initialize(data)
          @url = data["source"]
          super(data)
        end

        def render
          "#{EmojiAliaser.video} <a href='#{build_url}'>#{name}</a>"
        end

        private

        def build_name
          caption.empty? ? url : caption
        end
      end
    end
  end