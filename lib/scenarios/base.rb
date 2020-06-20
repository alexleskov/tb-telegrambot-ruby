# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        include Formatter
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
          answer.menu.after_auth
        rescue RuntimeError => e
          answer.menu.sign_in_again
        end

        def sign_out
          print_on_farewell
          appshell.logout
          print_farewell
          answer.menu.starting
        rescue RuntimeError => e
          answer.text.send_out "#{I18n.t('error')} #{e}"
        end

        def settings
          answer.menu.settings
        end

        def edit_settings
          answer.menu.edit_settings
        end

        def ready; end

        def choose_localization
          answer.menu.choosing("Setting", :localization)
        end

        def choose_scenario
          answer.menu.choosing("Setting", :scenario)
        end

        def change_language(lang)
          appshell.change_localization(lang.to_s)
          I18n.with_locale appshell.settings.localization.to_sym do
            print_on_save("localization", lang)
            answer.menu.starting
          end
        end

        def change_scenario(mode)
          appshell.change_scenario(mode)
          print_on_save("scenario", mode)
        end

        def check_status
          print_update_status(:in_progress)
          if yield
            print_update_status(:success)
            true
          else
            print_update_status(:fail)
            false
          end
        end
      end
    end
  end
end
