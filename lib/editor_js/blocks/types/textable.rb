# frozen_string_literal: true

  class EditorJs
    class Block
      class Textable < EditorJs::Block
        attr_reader :text

        def initialize(data)
          super(data)
          @text = data["text"]
        end
      end
    end
  end