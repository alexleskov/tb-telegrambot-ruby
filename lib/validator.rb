# frozen_string_literal: true

module Validator
  EMAIL_MASK = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  PASSWORD_MASK = /[\w|._#*^!+=@-]{6,40}$/.freeze
  PHONE_MASK = /^(8|\+7|7|\+3|3)(\d*)/.freeze

  attr_reader :value

  def validation(type, value)
    return unless value
    return value if type.to_sym == :none

    @value = value
    public_send(type)
  end

  def login
    email || phone
  end

  def email
    return unless value.match(EMAIL_MASK)

    value
  end

  def phone
    return unless value.match(PHONE_MASK)

    value
  end

  def password
    return unless value.match(PASSWORD_MASK)

    value
  end

  def string
    value.is_a?(String)
  end
end
