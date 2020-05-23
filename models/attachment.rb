# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Attachment < ActiveRecord::Base
      belongs_to :imageable, polymorphic: true
    end
  end
end
