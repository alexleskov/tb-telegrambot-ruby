require 'active_record'

module Teachbase
  module Bot
    class CourseSession < ActiveRecord::Base
      self.primary_key = 'cstb'
      belongs_to :user, dependent: :destroy
      has_many :sections, primary_key: 'cstb', foreign_key: 'section_cstb'
      has_many :materials

    end
  end
end
