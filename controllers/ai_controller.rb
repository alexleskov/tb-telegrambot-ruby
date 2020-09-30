# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class AIController < Teachbase::Bot::TextController
      attr_reader :ai, :reaction

      def initialize(params)
        @ai = Teachbase::Bot::AI.new
        super(params)
        @reaction = ai.find_reaction(text)
      end

      private

      def on(command)
        command =~ find_action
        return unless $LAST_MATCH_INFO

        yield
      end

      def find_action
        if reaction.is_a?(Sapcai::DialogMessage)
          @c_data = reaction.content
          "small_talks"
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
