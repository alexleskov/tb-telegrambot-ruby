# frozen_string_literal: true

class Breadcrumb
  include Formatter

  class << self
    def g(object, stages, params = {})
      new(object, stages, params).send(:build_crumbs)
    end
  end

  attr_reader :object, :stages, :params

  def initialize(object, stages, params)
    raise "Stages is '#{stages.class}'. Must be an Array" unless stages.is_a?(Array)

    if params
      raise "Params is '#{params.class}'. Must be a Hash" unless params.is_a?(Hash)
    end

    @object = object
    @stages = stages
    @params = params
  end

  def title
    return object.title if object.method(:title).parameters.empty?

    object.title(params)
  end

  def info
    I18n.t('information').to_s
  end

  def sections
    I18n.t('course_sections').to_s
  end

  def answers
    "\u21B3 #{Emoji.t(:speech_balloon)} #{I18n.t('answers').capitalize}"
  end

  alias contents sections

  def menu
    "#{attach_emoji(params[:state])} #{I18n.t(params[:state])}"
  end

  private

  def build_crumbs
    result = []
    stages.each { |stage| result << public_send(stage) }
    result << to_bolder(result.pop.dup)
    to_paragraph(result)
  end
end
