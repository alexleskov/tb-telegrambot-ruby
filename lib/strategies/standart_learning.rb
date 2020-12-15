module Teachbase
  module Bot
    class Strategies
      class StandartLearning < Teachbase::Bot::Strategies::Base
        include Teachbase::Bot::Strategies::ActionsList

        def starting
          interface.sys.menu.about_bot.show
          interface.sys.menu.starting.show
        end

        def demo_mode
          appshell.logout
          appshell.change_scenario(Teachbase::Bot::Strategies::DEMO_MODE_NAME)
          demo_mode_strategy = appshell.context.handle
          demo_mode_strategy.starting
        end

        def sign_in
          appshell.reset_to_default_scenario if demo_mode_on?
          interface.sys.text.on_enter(appshell.account_name).show
          auth = appshell.authorization
          raise unless auth

          appshell.data_loader.user.profile.me
          interface.sys.menu.greetings(appshell.user.profile_info(appshell.current_account.id)).show
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