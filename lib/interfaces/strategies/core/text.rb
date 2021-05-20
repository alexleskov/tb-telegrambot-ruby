# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Core
        class Text < Teachbase::Bot::Interfaces::Text
          def link(url, link_name)
            answer.content.url(link: url, link_name: link_name)
          end

          def update_status(status)
            @text = sign_by_status(status)
            self
          end

          def help_info
            @text = "#{Emoji.t(:information_source)} #{I18n.t('help_info')}"
            self
          end

          def on_enter(account_name)
            @text ||= "#{Emoji.t(:rocket)}<b>#{I18n.t('enter')} #{I18n.t('in')} #{account_name}</b>"
            self
          end

          def on_save(action, status)
            @text ||= "#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t(action.to_s)}: <b>#{I18n.t(status.to_s)}</b>"
            self
          end

          def on_empty
            on_empty_params
            self
          end

          def on_error(error = "Undefined error")
            @text ||= "#{Emoji.t(:crying_cat_face)}#{sign_on_error}: #{error}"
            self
          end

          def on_timeout
            @text ||= "#{Emoji.t(:alarm_clock)} #{I18n.t('timeout')}"
            @disable_notification = true
            self
          end

          def ask_enter_the_number(object_type)
            @text ||= "#{Emoji.t(:pencil2)} <b>#{I18n.t('enter_the_number')} #{sign_by_object_type(object_type)}:</b>"
            self
          end
        end
      end
    end
  end
end
