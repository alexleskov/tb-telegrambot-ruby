require 'active_record'

module Teachbase
  module Bot
    class CourseSession < ActiveRecord::Base
      belongs_to :user, dependent: :destroy
      has_many :sections
      has_many :materials

    end
  end
end
