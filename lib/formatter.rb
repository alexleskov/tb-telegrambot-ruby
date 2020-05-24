# frozen_string_literal: true

module Formatter
  NOT_VAILD_URL_REGEXP = %r{^(\/\/)}.freeze
  DEFAULT_URL_PROTOCOL = "http://"

  def to_bolder(string)
    "<b>#{string}</b>"
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

  def attach_emoji(sign)
    EmojiAliaser.respond_to?(sign) ? EmojiAliaser.public_send(sign) : EmojiAliaser.round_pushpin
  end

  def to_default_protocol(url)
    url_valid?(url) ? url : url.gsub(NOT_VAILD_URL_REGEXP, DEFAULT_URL_PROTOCOL)
  end

  def sanitize_html(html)
    Sanitize.fragment(html)
  end

  private

  def url_valid?(url)
    url !~ NOT_VAILD_URL_REGEXP
  end
end
