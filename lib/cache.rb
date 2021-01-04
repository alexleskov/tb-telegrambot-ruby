# frozen_string_literal: true

module Teachbase
  module Bot
    class Cache
      @all = []

      class << self
        attr_reader :all

        def save(entity, type)
          return unless entity.tg_user

          all << OpenStruct.new(message: entity, type: type.to_s, saved_at: Time.now.utc)
        end

        def extract_by(tg_user, type)
          return if !tg_user.is_a?(Teachbase::Bot::TgAccount) || all.empty?

          result = []
          all.reject! do |cached_message|
            if cached_message.message.handle.controller.tg_user.id == tg_user.id && cached_message.type == type.to_s
              result << cached_message
            end
          end
          result.sort_by!(&:saved_at).reverse!
        end

        def clean_up!
          @all = []
        end
      end
    end
  end
end
