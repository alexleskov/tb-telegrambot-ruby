module Teachbase
  module Bot
    module Scenarios
      module Base
        include Teachbase::Bot::Interfaces::Base

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
      end
    end
  end
end
