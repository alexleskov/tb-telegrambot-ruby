# frozen_string_literal: true

module Validator
  EMAIL_MASK = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  PASSWORD_MASK = /[\w|._#*^!+=@-]{6,40}$/.freeze
  PHONE_MASK = /^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$/.freeze

  attr_reader :value

  def validation(type, value)
    return unless value
    return value if type.to_sym == :none

    @value = value
    public_send(type)
  end

  def login
    value =~ EMAIL_MASK || PHONE_MASK
    Regexp.last_match
  end

  def email
    value =~ EMAIL_MASK
    Regexp.last_match
  end

  def phone
    value =~ PHONE_MASK
    Regexp.last_match
  end

  def password
    value =~ PASSWORD_MASK
    Regexp.last_match
  end

  def string
    value.is_a?(String)
  end
end
