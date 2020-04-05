module Teachbase
  module Bot
    module Scenarios
      module Base
        YOUTUBE_HOST = "https://youtu.be/"

        include Teachbase::Bot::Viewers::Base

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods; end

        def signin
          print_on_enter("teachbase")
          auth = appshell.authorization
          raise unless auth

          print_greetings("teachbase")
          menu.after_auth
        rescue RuntimeError => e
          menu.sign_in_again
        end

        def sign_out
          print_on_farewell
          appshell.logout
          print_farewell
          menu.starting
        rescue RuntimeError => e
          answer.send_out "#{I18n.t('error')} #{e}"
        end

        def settings
          menu.settings
        end

        def edit_settings
          menu.edit_settings
        end

        def choose_localization
          menu.choosing("Setting", :localization)
        end

        def choose_scenario
          menu.choosing("Setting", :scenario)
        end

        def change_language(lang)
          appshell.change_localization(lang.to_s)
          I18n.with_locale appshell.settings.localization.to_sym do
            print_on_save("localization", lang)
            menu.starting
          end
        end

        def change_scenario(mode)
          appshell.change_scenario(mode)
          print_on_save("scenario", mode)
        end

        def show_content_by_type(content)
          @logger.debug "content.attr: #{content.attributes}"
          case content.content_type.to_sym
          when :text
            answer.send_out(sanitize_html(content.content))
          when :image
            answer_content.photo(content.source)
          when :video
            answer_content.video(content.source)
          when :youtube
            answer_content.youtube("<a href='#{YOUTUBE_HOST}#{content.source}'>#{content.name}</a>")
          when :pdf
            answer_content.document(content.source)
          when :audio
            answer_content.audio(content.source)
          when :iframe
            open_button = prepeare_open_url_button(to_default_protocol(content.source), "\"#{content.name}\"")
          end
          menu_show_content(content, open_button)
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.error_code == 400
            @logger.debug "Error: #{e}"
            menu_show_content(content, prepeare_open_url_button(content.source, "\"#{content.name}\""))
          else
            answer.send_out(I18n.t('unexpected_error'))
          end
        end
      end
    end
  end
end
