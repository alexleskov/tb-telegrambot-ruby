# frozen_string_literal: true

class Teachbase::Bot::AnswerContent < Teachbase::Bot::AnswerController
  def create(options)
    super(options)
    MessageSender.new(msg_params).send
  end

  def photo(param)
    create(param)
  end

  def video(param)
    create(param)
  end

  def document(param)
    create(param)
  end

  def audio(param)
    create(param)
  end

  def url(param)
    create(text: to_url_link(param[:link], param[:link_name]))
  end

  def text(param)
    create(text: param)
  end

  def iframe(param)
    url(param)
  end

  def youtube(param)
    iframe(param)
  end

  def pdf(param)
    document(param)
  end
end
