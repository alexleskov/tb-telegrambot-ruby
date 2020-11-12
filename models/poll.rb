# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Poll < ActiveRecord::Base
      include Decorators::Poll

      belongs_to :course_session
      belongs_to :section
      belongs_to :user
      has_many :attachments, as: :imageable

      def can_submit?
        status == "new"
      end

      def description
        return if show_introduction

        introduction
      end
    end
  end
end
