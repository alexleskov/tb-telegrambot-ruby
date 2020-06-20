# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Task < ActiveRecord::Base
      include Viewers::Task

      belongs_to :course_session
      belongs_to :section
      belongs_to :user
      has_many :attachments, as: :imageable, dependent: :destroy
      has_many :answers, as: :answerable, dependent: :destroy

      def attachments?
        !attachments.empty?
      end

      def can_submit?
        %w[new declined].include?(status)
      end

      def cs_tb_id
        course_session.tb_id
      end
    end
  end
end
