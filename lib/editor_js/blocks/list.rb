# frozen_string_literal: true

class EditorJs
  class Block
    class List < EditorJs::Block
      attr_reader :items, :style

      def initialize(data)
        @items = data["items"]
        @style = data["style"]
        super(data)
      end

      def render
        result = []
        items.each_with_index do |item, ind|
          result << "#{build_mark(ind)} #{item}"
        end
        result.join(EditorJs::DELIMETER)
      end

      private

      def build_mark(index)
        style == "ordered" ? "#{index + 1}." : "•"
      end
    end
  end
  end
