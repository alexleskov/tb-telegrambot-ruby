module Formatter
  NOT_VAILD_URL_REGEXP = %r{^(\/\/)}
  DEFAULT_URL_PROTOCOL = "http://"

  def to_bolder(string)
    string.insert(0, "<b>").insert(-1, "</b>")
  end

  def to_camelize(string)
    string.to_s.split("_").collect(&:capitalize).join
  end

  def to_constantize(string, prefix = "")
    Kernel.const_get("#{prefix}#{string}")
  end

  def to_snakecase(string)
    string.to_s.gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr('-', '_').
    gsub(/\s/, '_').
    gsub(/__+/, '_').
    downcase
  end

  def to_i18n(array, prefix = "")
    raise "Given '#{array.class}'. Expected an Array" unless array.is_a?(Array)

    result = []
    array.each { |object| result << I18n.t("#{prefix}#{object}").capitalize }
    result
  end

  def attach_emoji(param)
    case param
    when :open
      Emoji.t(:arrow_forward)
    when :section_unable
      Emoji.t(:no_entry_sign)
    when :section_delayed
      Emoji.t(:no_entry_sign)
    when :section_unpublish
      Emoji.t(:x)
    when :materials, :text, :image, :video, :youtube, :pdf, :audio, :iframe
      Emoji.t(:page_facing_up)
    when :tasks
      Emoji.t(:memo)
    when :quizzes
      Emoji.t(:bar_chart)
    when :scorm_packages
      Emoji.t(:computer)
    end
  end

  def url_valid?(url)
    !(url =~ NOT_VAILD_URL_REGEXP)
  end

  def to_default_protocol(url)
    url_valid?(url) ? url : url.gsub(NOT_VAILD_URL_REGEXP, DEFAULT_URL_PROTOCOL)
  end

  def sanitize_html(html)
    Sanitize.fragment(html)
  end

end
