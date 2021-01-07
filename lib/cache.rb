# frozen_string_literal: true

module Teachbase
  module Bot
    class Cache
      @all = []

      class << self
        attr_reader :all

        def save(entity, type)
          return unless entity.tg_user

          all << OpenStruct.new(body: entity, tg_user_id: entity.tg_user.id, type: type.to_s, saved_at: Time.now.utc)
        end

        def extract_by(options)
          return if all.empty? || ([:tg_user, :type] & options.keys).empty?

          result = []
          all.reject! do |cached_message|
            tg_user_condition = same_tg_user?(options[:tg_user], cached_message) if options.keys.include?(:tg_user)
            type_condition = same_type?(options[:type].to_s, cached_message) if options.keys.include?(:type)
            result << cached_message if tg_user_condition || type_condition
          end
          result.sort_by!(&:saved_at).reverse!
          options.keys.include?(:group_by) ? result.group_by { |cached_message| cached_message.public_send(options[:group_by]) } : result
        end

        def clean_up!
          @all = []
        end

        def same_tg_user?(tg_user, cached_message)
          cached_message.body.handle.controller.tg_user.id == tg_user.id
        end

        def same_type?(type, cached_message)
          cached_message.type == type.to_s
        end
      end
    end
  end
end
