require 'active_record'

module Teachbase
  module Bot
    class Section < ActiveRecord::Base
      belongs_to :course_session, foreign_key: 'section_cstb', dependent: :destroy
      belongs_to :user, dependent: :destroy
      has_many :materials

    end
  end
end
