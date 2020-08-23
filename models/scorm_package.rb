# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class ScormPackage < ActiveRecord::Base
      include Viewers::ScormPackage

      belongs_to :course_session
      belongs_to :section
      belongs_to :user

      def can_submit?
        %w[new declined].include?(status)
      end
    end
  end
end
