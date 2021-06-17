# frozen_string_literal: true

  class EditorJs
    class Block
      class Quote < EditorJs::Block::Textable
        attr_reader :caption

        def initialize(data)
          @caption = data["caption"]
          super(data)
        end
        
        def render
          caption.empty? ? text : "#{text}\n<i>#{caption}</i>"
        end
      end
    end
  end