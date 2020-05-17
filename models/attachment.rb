# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Attachment < ActiveRecord::Base
      belongs_to :quiz
      belongs_to :task
    end
  end
end
