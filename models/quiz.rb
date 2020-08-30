# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Quiz < ActiveRecord::Base
      include Decorators::Quiz

      belongs_to :course_session
      belongs_to :section
      belongs_to :user
      has_many :attachments, as: :imageable

      def can_submit?
        %w[new failed passed].include?(status)
      end

      def active_status
        if is_incomplete
          "inprogress"
        else
          status
        end
      end
    end
  end
end
