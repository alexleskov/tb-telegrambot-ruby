# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Account < ActiveRecord::Base
      include Decorators::Account

      MAIN_ATTRS = %i[tb_id client_id client_secret name].freeze
      ADDIT_ATTRS = %i[curator_tg_id support_tg_id].freeze

      has_many :auth_sessions, dependent: :destroy
      has_many :users, through: :auth_sessions
      has_many :course_sessions, dependent: :destroy
      has_many :documents, dependent: :destroy
      has_many :categories, dependent: :destroy

      class << self
        def include_attribute?(attribute)
          (MAIN_ATTRS + ADDIT_ATTRS).include?(attribute.to_sym)
        end
      end
    end
  end
end
