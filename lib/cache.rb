# frozen_string_literal: true

module Teachbase
  module Bot
    class Cache
      class << self
        attr_reader :all

        def save(entity)
          return unless entity.tg_user

          @all << entity
        end

        def extract_by(tg_user)
          return unless tg_user.is_a?(Teachbase::Bot::TgAccount)

          result = nil
          @all.reject! do |entity|
            result = entity if entity.tg_user.id == tg_user.id
          end
          result
        end

        def clean_up!
          @all = []
        end
      end

      @all = []
    end
  end
end
