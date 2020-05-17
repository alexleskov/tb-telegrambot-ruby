# frozen_string_literal: true

require './lib/answers/answer'

class Teachbase::Bot::AnswerContent < Teachbase::Bot::Answer
  def initialize(appshell, param)
    super(appshell, param)
  end

  def create(options)
    super(options)
    MessageSender.new(msg_params).send
  end

  def photo(param)
    create(photo: param)
  end

  def video(param)
    create(video: param)
  end

  def document(param)
    create(document: param)
  end

  def audio(param)
    create(audio: param)
  end

  def url(link, link_name)
    create(text: "<a href='#{to_default_protocol(link)}'>#{link_name}</a>")
  end

  def text(param)
    create(text: param)
  end

  def iframe(param)
    link = param[:link]
    link_name = param[:link_name]
    url(link, link_name)
  end

  def youtube(param)
    iframe(param)
  end

  def pdf(param)
    document(param)
  end
end
