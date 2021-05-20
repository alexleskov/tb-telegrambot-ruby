# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class DemoMode < Teachbase::Bot::Strategies::Base
        def starting
          super
          result = registration
          return interface.sys.menu(text: I18n.t('declined')).starting.show unless result

          sign_in
        end

        def registration
          interface.sys.menu.take_contact.show
          contact = appshell.request_data(:none)
          raise unless contact.is_a?(Teachbase::Bot::ContactController)
          raise if contact.user_id != controller.context.tg_user.id

          appshell.authorizer.registration(contact, "193850" => "193851")
        rescue RuntimeError, TeachbaseBotException => e
          appshell.to_default_scenario
          appshell.logout
        end

        def sign_in
          auth = appshell.authorization
          raise unless auth

          appshell.data_loader.user.profile.me
          interface.sys.menu.greetings(appshell.user_fullname(:array).first).show
          interface.sys.content(file: "https://storage.yandexcloud.net/tbpublic/other/2868-300x300.png",
                                caption: "#{Emoji.t(:wave)} #{I18n.t('about_bot_demo_mode')}").photo
          interface.sys.menu.after_auth.show
        rescue RuntimeError, TeachbaseBotException => e
          $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
            appshell.logout
            title = "#{title} #{I18n.t('enter_by_auth_data').downcase} #{I18n.t('info_about_setted_password')}" if e.http_code == 401
            interface.sys.menu(text: title).sign_in_again.show
            appshell.to_default_scenario if appshell.user_settings.scenario == Teachbase::Bot::Strategies::DEMO_MODE_NAME
          end
          interface.sys.menu.starting.show
        end
      end
    end
  end
end
