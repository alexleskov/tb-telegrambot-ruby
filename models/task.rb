# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Task < ActiveRecord::Base
      belongs_to :course_session
      belongs_to :section
      belongs_to :user
    end
  end
end
