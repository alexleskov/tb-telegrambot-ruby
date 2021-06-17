# frozen_string_literal: true

class EditorJs
  class Block
    class Header < EditorJs::Block::Textable
      def render
        "<b>#{text}</b>"
      end
    end
  end
  end
