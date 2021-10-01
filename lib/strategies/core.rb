# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Core < Teachbase::Bot::Strategies
        include Teachbase::Bot::Strategies::ActionsList

        def administration
          with_tg_user_policy [:admin] do
            appshell.change_scenario(Teachbase::Bot::Strategies::ADMIN_MODE_NAME)
            interface.admin.menu.main.show
          end
        end

        def starting
          appshell.to_default_scenario
        end

        def help
          interface.sys.text.help_info.show
        end

        def demo_mode
          appshell.logout
          appshell.change_scenario(Teachbase::Bot::Strategies::DEMO_MODE_NAME)
          appshell.controller.context.handle.starting
        end

        def sign_out
          interface.sys.menu.farewell.show
          appshell.to_default_scenario if demo_mode?
          appshell.logout
          appshell.controller.context.handle
          appshell.controller.context.current_strategy.starting
        rescue RuntimeError => e
          interface.sys.text.on_error(e).show
        end

        alias closing sign_out

        def ready; end

        def decline; end

        def send_contact; end

        protected

        def admin
          with_tg_user_policy [:admin] do
            Teachbase::Bot::Strategies::Admin.new(controller)
          end
        end

        def demo_mode?
          controller.context.settings.scenario == DEMO_MODE_NAME
        end
      end
    end
  end
end
