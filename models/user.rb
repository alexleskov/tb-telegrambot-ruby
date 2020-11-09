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
        sessions_list = course_sessions
        option_key = params.map { |key, value| key if [:status, :tb_id].include?(key.to_sym) }.first
        query_param = { option_key.to_sym => params[option_key], account_id: params[:account_id] }
        if params[:scenario].to_s == "standart_learning"
          query_string = "#{option_key} IN (:#{option_key}) AND account_id = :account_id"
          query_param
        else
          sessions_list = sessions_list.joins('LEFT JOIN course_categories ON course_categories.course_session_id = course_sessions.id
                                               LEFT JOIN categories ON categories.id = course_categories.category_id')
          query_string = "course_sessions.#{option_key} IN (:#{option_key})
                         AND course_sessions.account_id = :account_id AND categories.name ILIKE :category"
          query_param[:category] = find_category_cname_by(params[:scenario])
          query_param
        end
        sessions_list = sessions_list.where(query_string, query_param)
        return sessions_list unless params[:limit] && params[:offset]

        sessions_list.limit(params[:limit]).offset(params[:offset])
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
        Teachbase::Bot::Scenarios::LIST.include?(name) ? I18n.t(name.to_s) : name
      end
    end
  end
end
