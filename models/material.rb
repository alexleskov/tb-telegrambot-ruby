# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Material < ActiveRecord::Base
      include Viewers::Material

      belongs_to :course_session
      belongs_to :section
      belongs_to :user

      class << self
        def show_by_user_cs_tbid(cs_tb_id, user_id, id)
          joins(:course_session)
          .where('course_sessions.tb_id = :cs_tb_id AND course_sessions.user_id = :user_id
                  AND materials.tb_id = :id', cs_tb_id: cs_tb_id, user_id: user_id, id: id)
        end
      end

    end
  end
end