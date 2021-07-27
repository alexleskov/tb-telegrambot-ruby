# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class StandartLearning < Teachbase::Bot::Strategies::Base
        def starting
          super
          interface.sys.menu.about_bot.show
          interface.sys.menu.starting.show
        end

        def sign_in
          appshell.to_default_scenario if demo_mode?
          interface.sys.text.on_enter(appshell.account_name).show
          auth = appshell.authorization
          raise unless auth

          user_profile
          interface.sys.menu.after_auth.show
        rescue RuntimeError, TeachbaseBotException => e
          $logger.debug "On auth error: #{e.class}. #{e.inspect}"
          title = to_text_by_exceiption_code(e)
          title = "#{I18n.t('accounts')}: #{title}" if e.is_a?(TeachbaseBotException::Account)
          appshell.logout if access_denied?(e) || e.is_a?(TeachbaseBotException::Account)
          interface.sys.menu.starting.show
          interface.sys.menu(text: title).sign_in_again.show
        end
      end
    end
  end
end
