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

  def youtube(param)
    create(text: param)
  end
end
