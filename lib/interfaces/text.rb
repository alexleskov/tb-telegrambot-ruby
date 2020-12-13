# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Text < Teachbase::Bot::InterfaceController
        def show
          answer.text.send_out(text, disable_notification)
        end

        def send_to(tg_id, from_user = "")
          @text ||= "#{I18n.t('incoming')} #{I18n.t('message').downcase} - #{from_user}:\n\n#{text}"
          answer.text.send_to(tg_id, text)
        end

        def on_undefined
          @text = I18n.t('undefined_text').to_s
          self
        end

        def on_undefined_action
          @text = I18n.t('undefined_action').to_s
          self
        end

        def on_forbidden
          @text = "#{Emoji.t(:x)} #{I18n.t('forbidden')}"
          self
        end

        def declined
          @text = "#{Emoji.t(:leftwards_arrow_with_hook)} <i>#{I18n.t('declined')}</i>"
          self
        end

        def ask_find_keyword
          @text = "#{Emoji.t(:pencil2)} #{I18n.t('enter_what_find')}:"
          self
        end

        def ask_next_action
          @text = "<i>#{I18n.t('start_menu_message')}</i>"
          self
        end

        def ask_login
          @text = "#{Emoji.t(:pencil2)} #{I18n.t('add_user_login')}:"
          self
        end

        def ask_password
          @text = "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:"
          self
        end

        def ask_answer
          @text = "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_answer')}:"
          self
        end

        def error
          @text = "#{Emoji.t(:boom)} <i>#{I18n.t('unexpected_error')}</i>"
          self
        end
      end
    end
  end
end
