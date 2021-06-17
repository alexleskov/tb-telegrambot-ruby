# frozen_string_literal: true

  class EditorJs
    class Block
      class Code < EditorJs::Block
        attr_reader :code

        def initialize(data)
          @code = data["code"]
          super(data)
        end

        def render
          "<pre>#{code}</pre>"
        end
      end
    end
  end