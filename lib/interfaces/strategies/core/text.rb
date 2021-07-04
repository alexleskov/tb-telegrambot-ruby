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
            @params[:text] = Phrase.status(status)
            self
          end

          def help_info
            @params[:text] = "#{Emoji.t(:information_source)} #{I18n.t('help_info')}"
            self
          end

          def on_enter(account_name)
            @params[:text] ||= "#{Emoji.t(:rocket)}<b>#{I18n.t('enter')} #{I18n.t('in')} #{account_name}</b>"
            self
          end

          def on_save(action, status)
            @params[:text] ||= "#{Emoji.t(:floppy_disk)} #{I18n.t('editted')}. #{I18n.t(action.to_s)}: <b>#{I18n.t(status.to_s)}</b>"
            self
          end

          def on_empty
            on_empty_params
            self
          end

          def on_error(error = "Undefined error")
            @params[:text] ||= "#{Emoji.t(:crying_cat_face)}#{Phrase.error}: #{error}"
            self
          end

          def on_timeout
            @params[:text] ||= "#{Emoji.t(:alarm_clock)} #{I18n.t('timeout')}"
            @params[:disable_notification] = true
            self
          end

          def ask_enter_the_number(object_type)
            @params[:text] ||= "#{Emoji.t(:pencil2)} <b>#{I18n.t('enter_the_number')} #{Phrase.by_object_type(object_type)}:</b>"
            self
          end
        end
      end
    end
  end
end
