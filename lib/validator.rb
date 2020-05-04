module Validator
  EMAIL_MASK = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  PASSWORD_MASK = /[\w|._#*^!+=@-]{6,40}$/.freeze
  PHONE_MASK = /^((8|\+7)[\- ]?)?(\(?\d{3}\)?[\- ]?)?[\d\- ]{7,10}$/.freeze
  
  def validation(type, value)
    return unless value

    case type
    when :login
      value =~ EMAIL_MASK || PHONE_MASK
    when :email
      value =~ EMAIL_MASK
    when :phone
      value =~ PHONE_MASK
    when :password
      value =~ PASSWORD_MASK
    when :string
      value.is_a?(String)
    end
  end
end