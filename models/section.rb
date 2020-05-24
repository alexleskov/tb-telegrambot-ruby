# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Section < ActiveRecord::Base
      include Viewers::Section

      OBJECTS = %i[materials scorm_packages quizzes tasks].freeze
      OBJECTS_CUSTOM_PARAMS = { materials: { "type" => :content_type },
                                scorm_packages: { "title" => :name } }.freeze
      OBJECTS_TYPES = { materials: :material,
                        scorm_packages: :scorm_package,
                        quizzes: :quiz,
                        tasks: :task }.freeze

      belongs_to :course_session
      belongs_to :user
      has_many :materials, dependent: :destroy
      has_many :scorm_packages, dependent: :destroy
      has_many :quizzes, dependent: :destroy
      has_many :tasks, dependent: :destroy

      def contents_by_types
        objects = {}
        OBJECTS.each do |content_type|
          objects[content_type] = public_send(content_type).order(position: :asc)
        end
        objects
      end

      def find_state
        if open?
          :open
        elsif unable?
          :section_unable
        elsif delayed?
          :section_delayed
        elsif unpublish?
          :section_unpublish
        end
      end

      def open?
        is_publish && is_available
      end

      def unable?
        is_publish && !is_available && !opened_at
      end

      def delayed?
        is_publish && !is_available && opened_at
      end

      def unpublish?
        !is_publish
      end
    end
  end
end
