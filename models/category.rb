# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Category < ActiveRecord::Base
      belongs_to :account
      has_many :course_categories, dependent: :destroy
      has_many :course_session, through: :course_categories

      class << self
        def find_by_name(string)
          where("name ILIKE ?", string).first
        end
      end
    end
  end
end
