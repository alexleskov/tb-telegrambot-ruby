# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class CourseCategory < ActiveRecord::Base
      belongs_to :course_session
      belongs_to :category
    end
  end
end
