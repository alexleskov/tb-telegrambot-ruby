# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Text < Teachbase::Bot::InterfaceController
        def show
          answer.text.send_out(params).push
        end

        def send_to(tg_id, from_user)
          return unless params[:text]

          answer.text.send_to(tg_id, Phrase.new(from_user).incoming_message(params[:text])).push
        end

        def on_undefined_contact
          @params[:text] = I18n.t('undefined_contact')
          self
        end

        def on_undefined
          @params[:text] = I18n.t('undefined_text')
          self
        end

        def on_undefined_action
          @params[:text] = I18n.t('undefined_action')
          self
        end

        def on_undefined_file
          @params[:text] = I18n.t('undefined_file')
          self
        end

        def on_forbidden
          @params[:text] = Phrase.forbidden
          self
        end

        def declined
          @params[:text] = Phrase.declined
          self
        end

        def ask_find_keyword
          @params[:text] = Phrase::Enter.keyword
          self
        end

        def ask_next_action
          @params[:text] = Phrase.start_action
          self
        end

        def ask_login
          @params[:text] = Phrase::Enter.login
          self
        end

        def ask_password(state)
          @params[:text] = Phrase::Enter.password.to_s
          @params[:text] = "#{params[:text]} #{I18n.t('new_password_condition').downcase}:" if state == :new
          self
        end

        def ask_answer
          @params[:text] = Phrase::Enter.answer
          self
        end

        def ask_value(name = "")
          @params[:text] = Phrase::Enter.value(name)
          self
        end

        def error
          @params[:text] = Phrase.error
          self
        end

        def password_changed
          @params[:text] = "#{Emoji.t(:thumbsup)} #{I18n.t('password_changed')}"
          self
        end
      end
    end
  end
end
