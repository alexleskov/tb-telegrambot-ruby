# frozen_string_literal: true

module Validator
  EMAIL_MASK = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  PASSWORD_MASK = /[\w|._#*^!+=@-]{6,40}$/.freeze
  PHONE_MASK = /^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$/.freeze

  attr_reader :value

  def validation(type, value)
    return unless value

    @value = value
    public_send(type)
  end

  def login
    value =~ EMAIL_MASK || PHONE_MASK
  end

  def email
    value =~ EMAIL_MASK
  end

  def phone
    value =~ PHONE_MASK
  end

  def password
    value =~ PASSWORD_MASK
  end

  def string
    value.is_a?(String)
  end
end
