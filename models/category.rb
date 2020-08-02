# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Category < ActiveRecord::Base
      has_many :course_categories, dependent: :destroy
      has_many :course_session, :through => :course_categories
    end
  end
end
