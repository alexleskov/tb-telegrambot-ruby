# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class CourseSession < ActiveRecord::Base
      STATES = %w[active archived].freeze
      include Decorators::CourseSession

      belongs_to :user
      belongs_to :account
      has_many :sections, dependent: :destroy
      has_many :materials, dependent: :destroy
      has_many :quizzes, dependent: :destroy
      has_many :tasks, dependent: :destroy
      has_many :scorm_packages, dependent: :destroy
      has_many :course_categories, dependent: :destroy
      has_many :categories, through: :course_categories

      def list_state(state)
        order(name: :asc).where(status: state.to_s)
      end

      def active?
        status == "active"
      end
    end
  end
end
