require 'active_record'

module Teachbase
  module Bot
    class Section < ActiveRecord::Base
      belongs_to :course_session
      belongs_to :user
      has_many :materials, dependent: :destroy
    end
  end
end
