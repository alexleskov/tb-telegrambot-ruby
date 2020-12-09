# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module DemoMode
        def starting
          result = registration
          return interface.sys.menu(text: I18n.t('declined')).starting.show unless result

          sign_in
        end

        def registration
          interface.sys.menu.take_contact.show
          contact = appshell.request_data(:none)
          raise unless contact.is_a?(Teachbase::Bot::ContactController)
          raise if contact.tg_user != tg_user.id

          appshell.authorizer.registration(contact, "193850" => "193851")
        rescue RuntimeError, TeachbaseBotException => e
          appshell.reset_to_default_scenario
          appshell.logout
        end

        def sign_in
          auth = appshell.authorization
          raise unless auth

          appshell.data_loader.user.profile.me
          interface.sys.menu.greetings(appshell.user_fullname(:array).first).show
          interface.sys.menu(disable_web_page_preview: false, text: I18n.t('about_bot_demo_mode')).after_auth.show
        rescue RuntimeError, TeachbaseBotException => e
          $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
            appshell.logout
            title = "#{title} #{I18n.t('enter_by_auth_data').downcase} #{I18n.t('info_about_setted_password')}" if e.http_code == 401
            appshell.reset_to_default_scenario if user_settings.scenario == Teachbase::Bot::Scenarios::DEMO_MODE_NAME
            interface.sys.menu(text: title).sign_in_again.show
          end
          interface.sys.menu.starting.show
        end

        def match_data
          super
        end

        def match_text_action
          super
        end
      end
    end
  end
end
