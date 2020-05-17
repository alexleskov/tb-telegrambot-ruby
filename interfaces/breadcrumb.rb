# frozen_string_literal: true

class Breadcrumb
  include Formatter

  DELIMETER = "\n"

  class << self
    def g(object, stages, params = {})
      new(object, stages, params).build_crumbs
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
    "#{Emoji.t(:information_source)} #{I18n.t('information')}"
  end

  def sections
    "#{Emoji.t(:arrow_down)} #{I18n.t('course_sections')}"
  end

  alias contents sections

  def menu
    "#{attach_emoji(params[:state])} #{I18n.t(params[:state])}"
  end

  def build_crumbs
    result = []
    stages.each { |stage| result << public_send(stage) }
    result << to_bolder(result.pop.dup) + DELIMETER
    result.join(DELIMETER)
  end
end
