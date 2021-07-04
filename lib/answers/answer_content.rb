# frozen_string_literal: true

class Teachbase::Bot::AnswerContent < Teachbase::Bot::AnswerMenu
  attr_reader :caption, :file, :content_type

  def create(options)
    @caption = options[:caption]
    @file = options[:file]
    super(options)
  end

  def photo(options)
    @content_type = :photo
    create(options)
  end

  def video(options)
    @content_type = :video
    create(options)
  end

  def document(options)
    @content_type = :document
    create(options)
  end

  def audio(options)
    @content_type = :audio
    create(options)
  end

  def url(options)
    create(text: to_url_link(options[:link], options[:link_name]))
  end

  def iframe(options)
    url(options)
  end

  def youtube(options)
    iframe(options)
  end

  def pdf(options)
    document(options)
  end
end
