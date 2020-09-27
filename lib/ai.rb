# frozen_string_literal: true

module Teachbase
  module Bot
    class AI
      SMALL_TALK_INTENTS_SLUG = %w[greetings creator].freeze

      attr_reader :client

      def initialize
        @client = Sapcai::Client.new($app_config.load_ai_token)
      end

      def find_reaction(text)
        nlp_result = analyse(text)
        nlp_result.intents.any? { |intent| SMALL_TALK_INTENTS_SLUG.include?(intent.slug) } ? message_by_small_talk(text) : nlp_result
      end

      def analyse(text)
        client.request.analyse_text(text)
      end

      def message_by_small_talk(text)
        messages_from_ai = client.build.dialog({ type: "text", content: text }, "777").messages
        return if messages_from_ai.empty?

        message = messages_from_ai.first
        return unless message && message.type == 'text'

        message
      end
    end
  end
end
