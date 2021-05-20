# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Admin < Teachbase::Bot::Strategies::Core
        def account(params = {})
          Teachbase::Bot::Strategies::Admin::Account.new(params, controller)
        end

        def starting
          super
          interface.sys.menu.starting.show
        end

        # TO DO: Aliases made for CommandController commands using. Will remove after refactoring.

        def accounts_manager
          admin.account.list
        end

        def new_account
          admin.account.add_new
        end
      end
    end
  end
end
