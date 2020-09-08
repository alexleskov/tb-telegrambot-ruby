# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      include Decorators::User

      has_one :profile, dependent: :destroy
      has_many :auth_sessions, dependent: :destroy
      has_many :tg_accounts, through: :auth_sessions
      has_many :course_sessions, dependent: :destroy

      def course_sessions_by(params)
        sessions_list = course_sessions.order(started_at: :desc)
        params[:scenario] ||= "standart_learning"
        result = if params[:scenario].to_s == "standart_learning"
                   sessions_list.where(status: params[:state].to_s)
                 else
                   sessions_list.joins('LEFT JOIN course_categories ON course_categories.course_session_id = course_sessions.id
                                        LEFT JOIN categories ON categories.id = course_categories.category_id')
                                .where('course_sessions.status = :status AND categories.name ILIKE :category', status: params[:state].to_s,
                                                                                                               category: find_category_cname_by(params[:scenario]))
                 end
        return result unless params[:limit] && params[:offset]

        result.limit(params[:limit]).offset(params[:offset])
      end

      def sections_by_cs_tbid(cs_tb_id)
        Teachbase::Bot::Section.list_by_user_cs_tbid(cs_tb_id, id)
      end

      def section_by_cs_tbid(cs_tb_id, section_id)
        Teachbase::Bot::Section.show_by_user_cs_tbid(cs_tb_id, section_id, id)
      end

      def material_by_cs_tbid(cs_tb_id, material_tb_id)
        Teachbase::Bot::Material.show_by_user_cs_tbid(cs_tb_id, material_tb_id, id).first
      end

      def task_by_cs_tbid(cs_tb_id, task_tb_id)
        Teachbase::Bot::Task.show_by_user_cs_tbid(cs_tb_id, task_tb_id, id).first
      end

      private

      def find_category_cname_by(name)
        I18n.t(name.to_s)
      end
    end
  end
end
