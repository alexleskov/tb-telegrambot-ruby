# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Answer < ActiveRecord::Base
      belongs_to :answerable, polymorphic: true
      has_many :attachments, as: :imageable, dependent: :destroy
      has_many :comments, as: :commentable, dependent: :destroy

      class << self
        def last_sent
          order(attempt: :desc).first
        end
      end

      def attachments?
        !attachments.empty?
      end

      def comments?
        !comments.empty?
      end
    end
  end
end
