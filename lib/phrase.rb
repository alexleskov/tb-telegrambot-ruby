# frozen_string_literal: true

module Phrase 
  class << self
    include Formatter
    
    def empty
      "<b>#{I18n.t('empty')}</b>"
    end

    def error
      "<b>#{I18n.t('error')}</b>"
    end

    def by_object_type(type)
      case type.to_sym
      when :section
        I18n.t('section3')
      else
        raise "No such sign for object type: '#{type}'"
      end
    end

    def entity_status(entity)
      return error unless entity.respond_to?(:status)

      "<b>#{I18n.t('state').capitalize}: #{attach_emoji(entity.status)} #{to_italic(I18n.t(entity.status).capitalize)}</b>"
    end

    def status(status)
      case status.to_sym
      when :in_progress
        "#{Emoji.t(:arrows_counterclockwise)} #{to_bolder(I18n.t('updating_data'))}"
      when :success
        "#{Emoji.t(:thumbsup)} #{I18n.t('updating_success')}"
      else
        "#{Emoji.t(:thumbsdown)} #{error}"
      end
    end

    def attachments
      "#{Emoji.t(:bookmark_tabs)} #{to_italic(I18n.t('attachments').capitalize)}"
    end

    def comments
      "#{Emoji.t(:lips)} #{to_italic(I18n.t('comments').capitalize)}"
    end

    def user_comment(comment)
      "<a href='#{comment.avatar_url}'>#{comment.user_name}</a> (#{Time.parse(Time.at(comment.tb_created_at)
                                                                        .strftime('%d.%m.%Y %H:%M'))
                                                                        .strftime('%d.%m.%Y %H:%M')}):
       — \"#{to_italic(comment.text)}\"\n"
    end

    def user_answer(answer)
      "<b>#{I18n.t('answer').capitalize} №#{answer.attempt}. #{I18n.t('state').capitalize}: #{attach_emoji(answer.status)} #{to_italic(I18n.t(answer.status).capitalize)}</b>
       \"#{sanitize_html(answer.text)}\""
    end

    def incoming_message(from_user, text)
      message_back_button = from_user.link_on ? "#{I18n.t('send')} #{I18n.t('answer').downcase}: #{from_user.link_on}" : ""
      ["#{I18n.t('incoming')} #{I18n.t('message').downcase} - #{from_user.to_full_name(:string)}:\n", text, message_back_button].join("\n")
    end

  end
end