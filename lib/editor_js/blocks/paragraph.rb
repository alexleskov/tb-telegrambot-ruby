# frozen_string_literal: true

class EditorJs
  class Block
    class Paragraph < EditorJs::Block::Textable
      def render
        text
      end
    end
  end
  end
