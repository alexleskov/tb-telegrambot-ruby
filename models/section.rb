require 'active_record'

module Teachbase
  module Bot
    class Section < ActiveRecord::Base
      belongs_to :course_session, dependent: :destroy
      belongs_to :user, dependent: :destroy
      has_many :materials

    end
  end
end
