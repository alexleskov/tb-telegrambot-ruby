require 'active_record'

module Teachbase
  module Bot
    class CourseSession < ActiveRecord::Base
      belongs_to :users, dependent: :destroy

    end
  end
end
