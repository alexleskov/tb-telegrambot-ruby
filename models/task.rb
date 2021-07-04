# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Task < ActiveRecord::Base
      include Decorators::Task

      belongs_to :course_session
      belongs_to :section
      belongs_to :user
      has_many :attachments, as: :imageable, dependent: :destroy
      has_many :answers, as: :answerable, dependent: :destroy

      class << self
        def show_by_user_cs_tbid(cs_tb_id, id, user_id)
          joins(:course_session)
            .where('course_sessions.tb_id = :cs_tb_id AND course_sessions.user_id = :user_id
                  AND tasks.tb_id = :id', cs_tb_id: cs_tb_id, user_id: user_id, id: id)
        end

        def type_like_sym
          :task
        end
      end

      def attachments?
        !attachments.empty?
      end

      def can_submit?
        %w[new declined].include?(status)
      end

      def can_comment?
        !!answers.last_sent
      end

      def cs_tb_id
        course_session.tb_id
      end
    end
  end
end
