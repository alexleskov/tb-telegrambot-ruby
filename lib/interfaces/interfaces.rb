# frozen_string_literal: true

require './lib/interfaces/types'
require './lib/answers/answers'

module Teachbase
  module Bot
    class Interfaces
      class << self
        attr_accessor :sys_class
        attr_reader :answers_controller

        def configure(respond, dest)
          @answers_controller = Teachbase::Bot::Answers.new(respond, dest)
          @sys_class = Teachbase::Bot::Interfaces::Base
        end

        def cs(entity = nil)
          self::CourseSession.new(entity)
        end

        def material(entity = nil)
          self::Material.new(entity)
        end

        def task(entity = nil)
          self::Task.new(entity)
        end

        def scorm_package(entity = nil)
          self::ScormPackage.new(entity)
        end

        def quiz(entity = nil)
          self::Quiz.new(entity)
        end

        def poll(entity = nil)
          self::Poll.new(entity)
        end

        def user(entity = nil)
          self::User.new(entity)
        end

        def section(entity = nil)
          self::Section.new(entity)
        end

        def sys(entity = nil)
          sys_class.new(entity)
        end

        def destroy(params)
          answers_controller.destroy.create(params)
        end
      end
    end
  end
end
