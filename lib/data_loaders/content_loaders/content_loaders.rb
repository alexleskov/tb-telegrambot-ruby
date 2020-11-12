# frozen_string_literal: true

require './lib/data_loaders/content_loader_controller'
require './lib/data_loaders/content_loaders/material_loader'
require './lib/data_loaders/content_loaders/task_loader'
require './lib/data_loaders/content_loaders/scorm_package_loader'
require './lib/data_loaders/content_loaders/quiz_loader'
require './lib/data_loaders/content_loaders/poll_loader'

module Teachbase
  module Bot
    class ContentLoaders
      def initialize(appshell, section_loader)
        raise "'#{appshell}' is not AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)
        raise "'#{section_loader} is not SectionLoader" unless section_loader.is_a?(Teachbase::Bot::SectionLoader)

        @appshell = appshell
        @section_loader = section_loader
      end

      def load_by(params)
        raise unless respond_to?(params[:type]) && params[:tb_id]

        public_send(params[:type], tb_id: params[:tb_id])
      end

      def material(params)
        Teachbase::Bot::MaterialLoader.new(@appshell, @section_loader, params)
      end

      def task(params)
        Teachbase::Bot::TaskLoader.new(@appshell, @section_loader, params)
      end

      def scorm_package(params)
        Teachbase::Bot::ScormPackageLoader.new(@appshell, @section_loader, params)
      end

      def quiz(params)
        Teachbase::Bot::QuizLoader.new(@appshell, @section_loader, params)
      end

      def poll(params)
        Teachbase::Bot::PollLoader.new(@appshell, @section_loader, params)
      end
    end
  end
end
