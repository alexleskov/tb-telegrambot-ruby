# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Comment < ActiveRecord::Base
      belongs_to :commentable, polymorphic: true
    end
  end
end
