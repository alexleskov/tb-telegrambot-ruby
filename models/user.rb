# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      include Decorators::User

      has_many :profiles, dependent: :destroy
      has_many :auth_sessions, dependent: :destroy
      has_many :tg_accounts, through: :auth_sessions
      has_many :course_sessions, dependent: :destroy
      has_many :documents, dependent: :destroy

      class << self
        def last_tg_account(tb_id)
          find_by(tb_id: tb_id).auth_sessions.where.not(auth_at: nil).order(auth_at: :desc)
        end
      end

      def course_sessions_by(params)
        params[:scenario] ||= "standart_learning"
        sessions_list = course_sessions
        option_key = params.map { |key, _value| key if %i[status tb_id name].include?(key.to_sym) }.first
        query_param = { option_key.to_sym => params[option_key], account_id: params[:account_id] }
        query_string =
          if params[:scenario].to_s == "standart_learning"
            "#{option_key} #{find_params(option_key)} AND account_id = :account_id"
          else
            sessions_list = sessions_list.joins('LEFT JOIN course_categories ON course_categories.course_session_id = course_sessions.id
                                                 LEFT JOIN categories ON categories.id = course_categories.category_id')
            query_param[:category] = find_category_cname_by(params[:scenario])
            "course_sessions.#{option_key} #{find_params(option_key)}
             AND course_sessions.account_id = :account_id AND categories.name ILIKE :category"
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

      def current_profile(account_id)
        profiles.find_by(account_id: account_id)
      end

      private

      def find_params(option_key)
        case option_key.to_sym
        when :name
          "ILIKE :#{option_key}"
        else
          "IN (:#{option_key})"
        end
      end

      def find_category_cname_by(name)
        Teachbase::Bot::Strategies::LIST.include?(name) ? I18n.t(name.to_s) : name
      end
    end
  end
end
