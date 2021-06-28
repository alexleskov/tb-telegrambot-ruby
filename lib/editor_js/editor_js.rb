# frozen_string_literal: true

require './lib/editor_js/block'
require './lib/editor_js/blocks/types/types'
require './lib/editor_js/blocks/blocks'

class EditorJs
  DELIMETER = "\n"
  HOST = "https://go.teachbase.ru"

  attr_reader :time, :parsed_blocks

  def initialize(content)
    @time = content["time"]
    @blocks = content["blocks"]
  end

  def valid?
    @blocks.is_a?(Array) && !@blocks.empty?
  end

  def parse
    return unless @blocks && valid?

    result = []
    @blocks.each do |block|
      result << send(block["type"], block["data"])
    end
    @parsed_blocks = result
    self
  end

  def render
    return unless parsed_blocks

    result = []
    parsed_blocks.each { |parsed_block| result << parsed_block.render + DELIMETER }
    result.join(DELIMETER) + DELIMETER
  end

  private

  def block_class
    EditorJs::Block
  end

  def header(data)
    block_class::Header.new(data)
  end

  def paragraph(data)
    block_class::Paragraph.new(data)
  end

  def image(data)
    block_class::Image.new(data)
  end

  def list(data)
    block_class::List.new(data)
  end

  def code(data)
    block_class::Code.new(data)
  end

  def quote(data)
    block_class::Quote.new(data)
  end

  def embed(data)
    block_class::Embed.new(data)
  end
end
