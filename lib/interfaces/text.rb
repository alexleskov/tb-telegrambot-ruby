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

          answer.text.send_to(tg_id, Phrase.new(from_user).incoming_message(text))
        end

        def on_undefined_contact
          @text = I18n.t('undefined_contact')
          self
        end

        def on_undefined
          @text = I18n.t('undefined_text')
          self
        end

        def on_undefined_action
          @text = I18n.t('undefined_action')
          self
        end

        def on_undefined_file
          @text = I18n.t('undefined_file')
          self
        end

        def on_forbidden
          @text = Phrase.forbidden
          self
        end

        def declined
          @text = Phrase.declined
          self
        end

        def ask_find_keyword
          @text = Phrase::Enter.keyword
          self
        end

        def ask_next_action
          @text = Phrase.start_action
          self
        end

        def ask_login
          @text = Phrase::Enter.login
          self
        end

        def ask_password(state)
          @text = Phrase::Enter.password
          @text = "#{text} #{I18n.t('new_password_condition').downcase}:" if state == :new
          self
        end

        def ask_answer
          @text = Phrase::Enter.answer
          self
        end

        def ask_value(name = "")
          @text = Phrase::Enter.value(name)
          self
        end

        def error
          @text = Phrase.error
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
