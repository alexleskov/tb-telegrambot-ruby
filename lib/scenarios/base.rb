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

        def signin(account_name = "teachbase")
          print_on_enter(account_name)
          auth = appshell.authorization
          raise unless auth

          print_greetings(account_name)
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

        def find_content_type(content)
          @logger.debug "content.attr: #{content.attributes}"
          case content
          when Teachbase::Bot::Material
            show_materials_by_type(content)
          else
            answer.send_out(I18n.t('unexpected_error'))
          end
        end

        def show_materials_by_type(content, back_button = true)
          source = content.source
          content_name = content.name
          section = content.section
          answer.send_out(content_title(content), disable_notification: true)
          case content.content_type.to_sym
          when :text
            answer.send_out(sanitize_html(content.content))
          when :image
            answer_content.photo(source)
          when :video
            answer_content.video(source)
          when :youtube
            answer_content.url("#{YOUTUBE_HOST}#{source}", content_name)
          when :pdf
            answer_content.document(source)
          when :audio
            answer_content.audio(source)
          when :iframe
            answer_content.url(source, "\"#{content_name}\"")      
          end
          prepare_section_back_button(section) if back_button
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.error_code == 400
            @logger.debug "Error: #{e}"
            menu.open_url_by_object(content)
            prepare_section_back_button(section) if back_button
          else
            answer.send_out(I18n.t('unexpected_error'))
          end 
        end

      end
    end
  end
end
