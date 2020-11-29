# frozen_string_literal: true

module Decorators
  module CourseSession
    include Formatter

    URL_WITHOUT_PARAMS = %r{^[^?]+}.freeze

    def time_by(option)
      raise "Can't get time by param: '#{option}" unless respond_to?(option)

      time = public_send(option)
      if time
        Time.parse(Time.at(time).strftime("%d.%m.%Y %H:%M")).strftime("%d.%m.%Y %H:%M")
      else
        sign_empty_date(option)
      end
    end

    def title(params = {})
      cover_url =
        if params && !params.empty?
          params[:cover_url]
        else
          URL_WITHOUT_PARAMS =~ icon_url
          $LAST_MATCH_INFO
        end
      "#{emoji_by_progress} <a href='#{cover_url}'>#{to_bolder(name)}</a>"
    end

    def statistics
      ["#{Emoji.t(:star2)}#{I18n.t('status')}: #{I18n.t("status_#{status}")}",
       "#{Emoji.t(:trophy)}#{I18n.t('success')}: #{I18n.t("success_#{success}")}",
       "#{Emoji.t(:chart_with_upwards_trend)}#{I18n.t('progress')}: #{progress}%",
       "#{Formatter::DELIMETER}#{I18n.t('started_at')}: #{time_by(:started_at)}",
       "#{I18n.t('deadline')}: #{time_by(:deadline)}"].join(Formatter::DELIMETER)
    end

    def categories_name
      return if categories.nil? || categories.empty?

      "#{I18n.t('categories')}: #{categories.pluck(:name).join(', ')}"
    end

    def sign_course_state
      to_bolder(I18n.t("cs_#{status}").capitalize).to_s
    end

    def sign_aval_sections_count_from
      "#{Formatter::DELIMETER}#{I18n.t('avaliable')} #{I18n.t('section3')}: #{sections.where(is_available: true).size} #{I18n.t('from')} #{sections.size}"
    end

    def sign_open(params)
      [title(params), "(#{time_by(:started_at)} — #{time_by(:deadline)})",
       "#{to_italic(I18n.t('open'))}: #{params[:route]}"].join("\n")
    end

    private

    def emoji_by_progress
      return Emoji.t(:new) unless progress
      
      progress.zero? && status != "archived" ? Emoji.t(:new) : Emoji.t(:book)
    end

    def sign_empty_date(option)
      option == :deadline ? "\u221e" : "-"
    end
  end
end
