# frozen_string_literal: true

require './controllers/controller'

module Teachbase
  module Bot
    class AIController < Teachbase::Bot::TextController
      attr_reader :ai, :reaction

      def initialize(params)
        @ai = Teachbase::Bot::AI.new
        super(params)
      end

      def find_reaction_by_ai
        @reaction = ai.find_reaction(text)
        return send_message(reaction.content) if reaction.is_a?(Sapcai::DialogMessage)

        reaction
      end

      def entities_slugs
        return if !skill? && reaction.entities.empty?

        # p "reaction.entities: #{reaction.entities}"
        result = []
        reaction.entities.each { |entity| result << entity.name }
        result
      end

      private

      def send_message(text)
        interface.sys.text.answer.text.send_out(text)
      end

      def on(skill_slug)
        find_reaction_by_ai
        return unless skill?

        # p "reaction.intents: #{reaction.intents}"
        skill_slug =~ reaction.intents.first.slug
        return unless $LAST_MATCH_INFO

        @c_data = reaction
        yield
      end

      def skill?
        return if reaction.nil? || reaction.is_a?(Sapcai::DialogMessage) || reaction.intents.empty?

        true
      end
    end
  end
end
