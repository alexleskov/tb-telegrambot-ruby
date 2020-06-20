# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      include Viewers::User

      has_one :profile, dependent: :destroy
      has_many :auth_sessions, dependent: :destroy
      has_many :tg_accounts, through: :auth_sessions
      has_many :course_sessions, dependent: :destroy

      def course_sessions_by(params)
        if params[:limit] && params[:offset]
          course_sessions.order(id: :asc).limit(params[:limit]).offset(params[:offset])
                         .where(status: params[:state].to_s, scenario_mode: params[:scenario])
        else
          course_sessions.order(id: :asc).where(status: params[:state].to_s, scenario_mode: params[:scenario])
        end
      end

      def sections_by_cs_tbid(cs_tb_id)
        Section.list_by_user_cs_tbid(cs_tb_id, id)
      end

      def section_by_cs_tbid(cs_tb_id, section_id)
        Section.show_by_user_cs_tbid(cs_tb_id, section_id, id)
      end

      def material_by_cs_tbid(cs_tb_id, material_tb_id)
        Material.show_by_user_cs_tbid(cs_tb_id, id, material_tb_id)
      end

      #appshell.user.course_sessions.find_by(tb_id: cs_tb_id).materials.find_by(tb_id: material_tb_id)

    end
  end
end
