# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Answer < ActiveRecord::Base
      belongs_to :answerable, polymorphic: true
      has_many :attachments, as: :imageable
    end
  end
end
