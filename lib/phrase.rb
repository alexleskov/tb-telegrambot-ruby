# frozen_string_literal: true

class Phrase
  include Formatter

  class << self
    include Formatter

    def empty
      "<b>#{I18n.t('empty')}</b>"
    end

    def error
      "#{Emoji.t(:boom)} <i>#{I18n.t('unexpected_error')}</i>"
    end

    def auth_failed
      "#{I18n.t('error')}. #{I18n.t('auth_failed')}\n#{I18n.t('try_again')}"
    end

    def forbidden
      "#{Emoji.t(:x)} #{I18n.t('forbidden')}"
    end

    def declined
      "#{Emoji.t(:leftwards_arrow_with_hook)} <i>#{I18n.t('declined')}</i>"
    end

    def start_action
      "<i>#{I18n.t('start_menu_message')}</i>"
    end

    def page_number(current_number, all_count)
      "#{I18n.t('page')} #{current_number} #{I18n.t('from')} #{all_count}"
    end

    def by_object_type(type)
      case type.to_sym
      when :section
        I18n.t('section3')
      else
        raise "No such sign for object type: '#{type}'"
      end
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

    def profile
      "<b>#{Emoji.t(:tiger)} #{I18n.t('profile_state')}</b>"
    end

    def attachments
      "#{Emoji.t(:package)} #{I18n.t('attachments').capitalize}"
    end

    def comments
      "#{Emoji.t(:lips)} #{I18n.t('comments').capitalize}"
    end

    def courses_list
      "<b>#{Emoji.t(:books)} #{I18n.t('cs_list')}</b>"
    end

    alias links attachments

    def more_actions
      "#{Emoji.t(:link)}#{I18n.t('more_actions')}"
    end

    def documents
      "#{Emoji.t(:school_satchel)}<b>#{I18n.t('documents')}</b>"
    end
  end

  class Enter
    class << self
      include Formatter

      def contact
        "#{I18n.t('meet_with_bot')}\n\n#{Emoji.t(:point_down)} #{I18n.t('click_to_send_contact')} #{I18n.t('notice_about_safety')}"
      end

      def keyword
        "#{Emoji.t(:pencil2)} #{I18n.t('enter_what_find')}:"
      end

      def login
        "#{Emoji.t(:pencil2)} #{I18n.t('add_user_login')}:"
      end

      def password
        "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:"
      end

      def answer
        "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_answer')}:"
      end

      def next_answer
        "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_next_answer')} #{Emoji.t(:point_down)}"
      end

      def value(name)
        "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_value')}#{name}:"
      end
    end
  end

  attr_reader :entity

  def initialize(entity)
    @entity = entity
  end

  def open_it
    "#{Emoji.t(:link)} #{I18n.t('open').capitalize}: #{entity.name}"
  end

  def status
    return error unless entity.respond_to?(:status)

    "<b>#{I18n.t('state').capitalize}: #{attach_emoji(entity.status)} #{to_italic(I18n.t(entity.status).capitalize)}</b>"
  end

  def comment
    "<a href='#{entity.avatar_url}'>#{entity.user_name}</a> <pre>(#{build_time(entity.tb_created_at)})</pre>:
     — \"#{to_italic(entity.text)}\"\n"
  end

  def answer
    "<b>#{I18n.t('answer').capitalize} №#{entity.attempt}:</b>\n
     #{sanitize_html(entity.text)}"
  end

  def incoming_message(text)
    message_back_button = entity.link_on ? "#{I18n.t('send')} #{I18n.t('answer').downcase}: #{entity.link_on}" : ""
    ["#{I18n.t('incoming')} #{I18n.t('message').downcase} - #{entity.to_full_name(:string)}:\n", text, message_back_button].join("\n")
  end

  private

  def build_time(timestamp)
    Time.parse(Time.at(timestamp).strftime("%d/%m/%Y %H:%M")).strftime("%d/%m/%Y %H:%M")
  end
end
