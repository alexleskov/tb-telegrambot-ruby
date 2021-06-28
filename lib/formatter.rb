# frozen_string_literal: true

module Formatter
  NOT_VAILD_URL_REGEXP = %r{^(\/\/|\/)}.freeze
  ONLY_FILE_NAME_REGEXP = %r{(.+?)(\.[^.]*$|$)}.freeze
  URL_REGEXP = %r{^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$}.freeze
  DEFAULT_URL_PROTOCOL = "http://"
  DELIMETER = "\n"
  TIME_F = "%d.%m.%Y %H:%M"

  def to_bolder(string)
    "<b>#{string}</b>"
  end

  def to_italic(string)
    "<i>#{string}</i>"
  end

  def to_camelize(string)
    string.to_s.split("_").collect(&:capitalize).join
  end

  def to_constantize(string, prefix = "")
    Kernel.const_get("#{prefix}#{string}")
  end

  def to_snakecase(string)
    string.to_s.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .gsub(/\s/, '_')
          .gsub(/__+/, '_')
          .downcase
  end

  def to_url_link(link, link_name)
    "<a href='#{to_default_protocol(link)}'>#{link_name}</a>"
  end

  def to_i18n(array, prefix = "")
    raise "Given '#{array.class}'. Expected an Array" unless array.is_a?(Array)

    result = []
    array.each { |object| result << I18n.t("#{prefix}#{object}").capitalize }
    result
  end

  def to_default_protocol(url)
    url_valid?(url) ? url : url.gsub(NOT_VAILD_URL_REGEXP, DEFAULT_URL_PROTOCOL)
  end

  def to_paragraph(array)
    raise "Given '#{array.class}'. Expected an Array" unless array.is_a?(Array)

    array.join(DELIMETER) + DELIMETER
  end

  def to_dash_from_zero(number)
    return "—" unless number

    return number unless number.is_a?(Integer)

    number.zero? ? "—" : number
  end

  def to_min(integer)
    integer.positive? ? integer / 60 : 0
  end

  def to_text_by_exceiption_code(error)
    return unless error.respond_to?(:http_code)

    result = if error.http_code == 401 || error.http_code == 403
               "#{I18n.t('forbidden')}\n#{I18n.t('try_again')}"
             elsif error.http_code == 404
               I18n.t('not_found').to_s
             end
    "#{I18n.t('error')}. #{result}"
  end

  def to_full_name(option = :string)
    user_name = [first_name, last_name]
    user_name = option == :string ? user_name.join(" ") : user_name
  end

  def chomp_file_name(url, mode = :with_extension)
    file_name = url.to_s.split('/')[-1]
    return file_name if mode == :with_extension

    ONLY_FILE_NAME_REGEXP =~ file_name
    return file_name unless $LAST_MATCH_INFO

    $LAST_MATCH_INFO[1]
  end

  def attach_emoji(sign)
    EmojiAliaser.respond_to?(sign) ? EmojiAliaser.public_send(sign) : "\u2022"
  end

  def sanitize_html(html)
    Sanitize.fragment(html)
  end

  def url?(string)
    !!(string =~ URL_REGEXP)
  end

  def button_sign_by_content_type(cont_type, object)
    type = object.respond_to?(:content_type) ? object.content_type : cont_type
    "#{attach_emoji(type)} #{attach_emoji(object.status)} #{object.name}"
  end

  private

  def url_valid?(url)
    url !~ NOT_VAILD_URL_REGEXP
  end
end
