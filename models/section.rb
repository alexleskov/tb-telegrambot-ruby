require 'active_record'

module Teachbase
  module Bot
    class Section < ActiveRecord::Base
      belongs_to :course_session
      belongs_to :user
      has_many :materials, dependent: :destroy
      has_many :scorm_packages, dependent: :destroy
      has_many :quizzes, dependent: :destroy
      has_many :tasks, dependent: :destroy
    end
  end
end
