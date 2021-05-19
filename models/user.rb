# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class User < ActiveRecord::Base
      include Decorators::User

      TYPE_TABLES = { cs: "course_sessions", document: "documents" }.freeze

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

      def find_all_by_type(type, params)
        option_key = params.map { |key, _value| key if %i[status tb_id name].include?(key.to_sym) }.first
        query_param = { option_key.to_sym => params[option_key], account_id: params[:account_id] }
        case type.to_sym
        when :cs
          params[:scenario] ||= Teachbase::Bot::Strategies::STANDART_LEARNING_NAME
          list = course_sessions
          unless params[:scenario].to_s == Teachbase::Bot::Strategies::STANDART_LEARNING_NAME
            list = list.joins('LEFT JOIN course_categories ON course_categories.course_session_id = course_sessions.id
                               LEFT JOIN categories ON categories.id = course_categories.category_id')
            query_param[:category] = find_category_cname_by(params[:scenario]) if params[:scenario]
          end
        when :document
          list = documents
        else
          raise "Don't know such type: '#{type}'"
        end
        query_string = build_query_string(type, option_key: option_key, query_param: query_param, scenario: params[:scenario])
        list = list.where(query_string, query_param)
        return list unless params[:limit] && params[:offset]

        list.limit(params[:limit]).offset(params[:offset])
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

      def build_query_string(type, options)
        table_name = TYPE_TABLES[type.to_sym]
        raise "Don't know such table type: '#{type}'" unless table_name

        default_query_string = "#{options[:option_key]} #{find_params(options[:option_key])} AND #{table_name}.account_id = :account_id"
        result_query_string =
          case type.to_sym
          when :cs
            if options[:scenario].to_s != Teachbase::Bot::Strategies::STANDART_LEARNING_NAME
              "#{default_query_string} AND categories.name ILIKE :category"
            else
              default_query_string
            end
          else
            default_query_string
          end
        "#{table_name}.#{result_query_string}"
      end

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
