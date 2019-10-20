require 'active_record'

module Teachbase
  module Bot
    class CourseSession < ActiveRecord::Base
      belongs_to :user
      has_many :sections

    end
  end
end
