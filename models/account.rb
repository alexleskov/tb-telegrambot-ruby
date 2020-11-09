# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Account < ActiveRecord::Base
      has_many :auth_sessions, dependent: :destroy
      has_many :users, through: :auth_sessions
      has_many :course_sessions, dependent: :destroy
      has_many :categories, dependent: :destroy

      class << self
        def find_all_matches_by_tbid(array)
          where(tb_id: array)
        end
      end
    end
  end
end
