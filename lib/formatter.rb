# frozen_string_literal: true

module Formatter
  NOT_VAILD_URL_REGEXP = %r{^(\/\/|\/)}.freeze
  ONLY_FILE_NAME_REGEXP = %r{(.+?)(\.[^.]*$|$)}.freeze
  URL_REGEXP = %r{^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-zA-Z0-9]+([\-\.]{1}[a-zA-Z0-9]+)*\.[a-zA-Z]{2,5}(:[0-9]{1,5})?(\/.*)?$}.freeze
  DEFAULT_URL_PROTOCOL = "http://"
  DELIMETER = "\n"
  HOST = "https://go.teachbase.ru"

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

  def chomp_file_name(url, mode = :with_extension)
    file_name = url.to_s.split('/')[-1]
    return file_name if mode == :with_extension

    ONLY_FILE_NAME_REGEXP =~ file_name
    return file_name unless $1

    $1
  end

  def to_text_by_editorjs(editorjs_content)
    result = []
    editorjs_content["blocks"].each do |block|
      result << build_text_block_by_data_type(block) + DELIMETER
    end
    to_paragraph(result)
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

  def to_text_by_exceiption_code(error)
    return unless error.respond_to?(:http_code)

    result = if error.http_code == 401 || error.http_code == 403
               "#{I18n.t('forbidden')}\n#{I18n.t('try_again')}"
             elsif error.http_code == 404
               "#{I18n.t('not_found')}"
             end
    "#{I18n.t('error')}. #{result}"
  end

  private

  def build_text_block_by_data_type(block)
    raise "Given '#{block.class}'. Expected a Hash" unless block.is_a?(Hash)

    data = block["data"]
    case block["type"]
    when "header"
      to_bolder(data["text"])
    when "paragraph"
      data["text"]
    when "image"
      url = data["file"]["url"]
      image_name = data["caption"].empty? ? chomp_file_name(url, :only_name) : data["caption"]
      attach_emoji(:image) + to_url_link("#{HOST}#{url}", image_name)
    when "list"
      result = []
      data["items"].each_with_index do |item, ind|
        mark = data["style"] == "ordered" ? "#{ind + 1}." : "•"
        result << "#{mark} #{item}"
      end
      to_paragraph(result)
    when "code"
      "<pre>#{data['code']}</pre>"
    when "quote"
      data["caption"].empty? ? data["text"] : "#{data['text']}\n#{to_italic(data['caption'])}"
    else
      "Undefined content"
    end
  end

  def url_valid?(url)
    url !~ NOT_VAILD_URL_REGEXP
  end
end
