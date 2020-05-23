# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Task < ActiveRecord::Base
      include Viewers::Task

      belongs_to :course_session
      belongs_to :section
      belongs_to :user
      has_many :attachments, as: :imageable

    end
  end
end
