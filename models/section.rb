require 'active_record'

module Teachbase
  module Bot
    class Section < ActiveRecord::Base
      include Viewers::Section

      belongs_to :course_session
      belongs_to :user
      has_many :materials, dependent: :destroy
      has_many :scorm_packages, dependent: :destroy
      has_many :quizzes, dependent: :destroy
      has_many :tasks, dependent: :destroy

      def find_state
        if is_open?
          :open
        elsif is_unable?
          :section_unable
        elsif is_delayed?
          :section_delayed
        elsif is_unpublish?
          :section_unpublish
        end
      end

      def is_open?
        is_publish && is_available
      end

      def is_unable?
        is_publish && !is_available && !opened_at
      end

      def is_delayed?
        is_publish && !is_available && opened_at
      end

      def is_unpublish?
        !is_publish
      end

    end
  end
end
