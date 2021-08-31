# frozen_string_literal: true

module Teachbase
  module Bot
    class Authorizer
      class Base
        attr_reader :client_id, :client_secret, :account_tb_id, :login_type, :login

        def initialize(authsession, account_credentials = {})
          raise "account_credentials must be a Hash" unless account_credentials.is_a?(Hash)

          @authsession = authsession
          @account_tb_id = @authsession&.account ? @authsession.account.tb_id : account_credentials[:account_id]
          @client_id = account_credentials[:client_id] || $app_config.client_id
          @client_secret = account_credentials[:client_secret] || $app_config.client_secret
        end

        protected

        def build_oauth_params
          { account_id: account_tb_id || $app_config.account_id, client_id: client_id, client_secret: client_secret }
        end

        def build_login_and_type(data)
          @login_type = kind_of_login(data[:login])
          @login = login_type == :phone ? data[:login].to_i.to_s : data[:login]
        end

        def kind_of_login(login_data)
          case login_data
          when Validator::EMAIL_MASK
            :email
          when Validator::PHONE_MASK
            :phone
          end
        end
      end
    end
  end
end
