# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class AIController < Teachbase::Bot::TextController
      SMALL_TALKS_SKILL_NAME = "small_talks"

      attr_reader :ai, :reaction, :action

      def initialize(params)
        @ai = Teachbase::Bot::AI.new
        @type = "ai"
        super(params)
        @reaction = ai.find_reaction(source)
      end

      def on(command)
        @action = find_action
        return unless action

        command =~ "/ai:#{action}"
        return unless $LAST_MATCH_INFO

        yield
      end

      private

      def find_action
        if reaction.is_a?(Sapcai::DialogMessage)
          @c_data = reaction.content
          SMALL_TALKS_SKILL_NAME
        elsif skill?
          @c_data = entities_by_skill
          reaction.intent.slug
        end
      end

      def skill?
        reaction&.is_a?(Sapcai::Response) && !reaction.intents.empty?
      end

      def entities_by_skill
        return if !skill? && reaction.entities.empty?

        YAML.safe_load(reaction.raw)["results"]["entities"]
      end
    end
  end
end
