# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Base
        attr_reader :client_id, :client_secret, :account_tb_id

        def initialize(appshell, authsession, account_credentials = {})
          raise "'#{appshell}' is not Teachbase::Bot::AppShell" unless appshell.is_a?(Teachbase::Bot::AppShell)

          @appshell = appshell
          @authsession = authsession
          @account_tb_id = @authsession&.account ? @authsession.account.tb_id : account_credentials[:account_id]
          @client_id = account_credentials[:client_id] || $app_config.client_id
          @client_secret = account_credentials[:client_secret] || $app_config.client_secret
        end

        protected

        def build_oauth_params
          { account_id: account_tb_id || $app_config.account_id, client_id: client_id, client_secret: client_secret }
        end
      end
    end
  end
end
