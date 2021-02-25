# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Text < Teachbase::Bot::InterfaceController
        def show
          answer.text.send_out(text, disable_notification)
        end

        def send_to(tg_id, from_user)
          return unless text

          link_on_user =
            if from_user.respond_to?(:link_on) && from_user.link_on
              "#{I18n.t('send')} #{I18n.t('answer').downcase}: #{from_user.link_on}"
            end
          message_to_user = ["#{I18n.t('incoming')} #{I18n.t('message').downcase} - #{from_user.to_full_name(:string)}:\n",
                             text.to_s, link_on_user || ""].join("\n")
          answer.text.send_to(tg_id, message_to_user)
        end

        def on_undefined_contact
          @text = I18n.t('undefined_contact').to_s
          self
        end

        def on_undefined
          @text = I18n.t('undefined_text').to_s
          self
        end

        def on_undefined_action
          @text = I18n.t('undefined_action').to_s
          self
        end

        def on_undefined_file
          @text = I18n.t('undefined_file').to_s
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

        def ask_password(state)
          @text = "#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:"
          @text = "#{text} #{I18n.t('new_password_condition').downcase}:" if state == :new
          self
        end

        def ask_answer
          @text = "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_answer')}:"
          self
        end

        def ask_value(value_name = "")
          @text = "#{Emoji.t(:pencil2)} #{I18n.t('enter_your_value')}#{value_name}:"
          self
        end

        def error
          @text = "#{Emoji.t(:boom)} <i>#{I18n.t('unexpected_error')}</i>"
          self
        end

        def password_changed
          @text = "#{Emoji.t(:thumbsup)} #{I18n.t('password_changed')}"
          self
        end
      end
    end
  end
end
