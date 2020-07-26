# frozen_string_literal: true

require './lib/interfaces/types'

module Teachbase
  module Bot
    class Interfaces
      attr_accessor :sys_class

      def initialize(respond, dest)
        @answer = Teachbase::Bot::Answers.new(respond, dest)
        @sys_class = Teachbase::Bot::Interfaces::Base
      end

      def cs(entity = nil)
        Teachbase::Bot::Interfaces::CourseSession.new(@answer, entity)
      end

      def material(entity)
        Teachbase::Bot::Interfaces::Material.new(@answer, entity)
      end

      def task(entity)
        Teachbase::Bot::Interfaces::Task.new(@answer, entity)
      end

      def scorm_package(entity)
        Teachbase::Bot::Interfaces::ScormPackage.new(@answer, entity)
      end

      def quiz(entity)
        Teachbase::Bot::Interfaces::Quiz.new(@answer, entity)
      end

      def user(entity)
        Teachbase::Bot::Interfaces::User.new(@answer, entity)
      end

      def section(entity)
        Teachbase::Bot::Interfaces::Section.new(@answer, entity)
      end

      def sys(entity = nil)
        sys_class.new(@answer, entity)
      end
    end
  end
end
