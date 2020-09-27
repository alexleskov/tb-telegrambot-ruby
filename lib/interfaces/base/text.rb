# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Base
        class Text < Teachbase::Bot::InterfaceController
          def on_enter
            answer.text.send_out("#{Emoji.t(:rocket)}<b>#{I18n.t('enter')} #{I18n.t('in')} #{params[:account_name]}</b>")
          end

          def about_bot
            answer.menu.hide(I18n.t('about_bot').to_s)
          end

          def greetings
            answer.menu.hide("<b>#{params[:user_name]}!</b> #{I18n.t('greetings')} #{I18n.t('in')} #{params[:account_name]}!")
          end

          def farewell
            answer.menu.hide("<b>#{params[:user_name]}!</b> #{I18n.t('farewell_message')} #{Emoji.t(:crying_cat_face)}")
          end

          def on_farewell
            answer.text.send_out("#{Emoji.t(:door)}<b>#{I18n.t('sign_out')}</b>")
          end

          def on_save(action, status)
            answer.text.send_out("#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t(action.to_s)}: <b>#{I18n.t(status.to_s)}</b>")
          end

          def link(url, link_name)
            answer.content.url(link: url, link_name: link_name)
          end

          def update_status(status)
            answer.text.send_out(sign_by_status(status))
          end

          def ask_enter_the_number(object_type)
            answer.text.send_out("#{Emoji.t(:pencil2)} <b>#{I18n.t('enter_the_number')} #{sign_by_object_type(object_type)}:</b>")
          end

          def on_empty(title_options = { text: "" })
            params[:text] ||= "#{create_title(title_options)}\n"
            answer.text.send_out("\n#{params[:text]}\n#{sing_on_empty}")
          end

          def ask_next_action
            answer.text.send_out("<i>#{I18n.t('start_menu_message')}</i>")
          end

          def on_error(error = "Undefined error")
            answer.text.send_out("#{Emoji.t(:crying_cat_face)}#{sign_on_error}: #{error}")
          end

          def on_undefined_action
            answer.text.send_out(I18n.t('undefined_action').to_s)
          end

          def on_forbidden
            answer.text.send_out("#{Emoji.t(:x)} #{I18n.t('forbidden')}")
          end

          def declined
            answer.text.send_out("#{Emoji.t(:leftwards_arrow_with_hook)} <i>#{I18n.t('declined')}</i>")
          end

          def ask_login
            answer.text.send_out("#{Emoji.t(:pencil2)} #{I18n.t('add_user_login')}:")
          end

          def ask_password
            answer.text.send_out("#{Emoji.t(:pencil2)} #{I18n.t('add_user_password')}:")
          end

          def ask_answer
            answer.text.ask_answer(params[:text])
          end
        end
      end
    end
  end
end
