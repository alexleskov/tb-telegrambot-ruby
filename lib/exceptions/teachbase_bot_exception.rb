# frozen_string_literal: true

class TeachbaseBotException < StandardError
  attr_reader :http_code

  def initialize(msg = "TeachbaseBotError", http_code)
    @http_code = http_code.to_i
    super(msg)
  end
end