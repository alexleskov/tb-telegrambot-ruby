# frozen_string_literal: true

require './lib/data_loaders/data_loader_controller'
require './lib/data_loaders/user_loader'
require './lib/data_loaders/course_session_loader'
require './lib/data_loaders/profile_loader'
require './lib/data_loaders/section_loader'
require './lib/data_loaders/content_loaders/content_loaders'

module Teachbase
  module Bot
    class DataLoaders
      def initialize(appshell)
        raise "'#{appshell}' is not AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

        @appshell = appshell
      end

      def cs(params = {})
        Teachbase::Bot::CourseSessionLoader.new(@appshell, params)
      end

      def user
        Teachbase::Bot::UserLoader.new(@appshell)
      end

      def section(params)
        Teachbase::Bot::SectionLoader.new(@appshell, params)
      end
    end
  end
end
