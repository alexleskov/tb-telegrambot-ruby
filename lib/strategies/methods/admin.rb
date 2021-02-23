# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Admin < Teachbase::Bot::Strategies
        def initialize(controller, options)
          super(controller)
        end

        def accounts
          with_tg_user_policy [:admin] do
            accounts_list = Teachbase::Bot::Account.all.order(name: :asc)
            interface.sys.menu.decline.show
            data = appshell.request_user_account_data(accounts_list, [:statuses, :tb_ids])
            return interface.sys.menu(text: I18n.t('declined')).administration.show unless data

            account = Teachbase::Bot::Account.find_by(tb_id: data.to_i)
            return interface.sys.on_empty.show unless account

            interface.sys.menu.administration.show
            interface.admin(account).menu.account.show
          end
        end

        def add_new_account
          with_tg_user_policy [:admin] do
            new_account_params = {}
            Teachbase::Bot::Account::MAIN_ATTRS.each do |attribute|
              interface.sys.text.ask_value(" #{attribute}").show
              value = appshell.ask_answer(mode: :once).source
              attribute == :tb_id ? value.to_i : value.to_s
              new_account_params[attribute.to_sym] = value
            end
            new_account_attrs_list = Teachbase::Bot::Account::MAIN_ATTRS - new_account_params.keys
            return interface.sys.text.error.show unless new_account_attrs_list.empty?

            ping_result = nil
            result =
            check_status(:default) do
              ping_result = appshell.authorizer.ping(account_id: new_account_params[:tb_id], client_id: new_account_params[:client_id],
                                                     client_secret: new_account_params[:client_secret])
              ping_result.is_a?(RestClient::Unauthorized) ? nil : Teachbase::Bot::Account.create!(new_account_params)
            end
            result ? result : interface.sys.text(text: ping_result).show
          end
        end

        def update_account(account_tb_id, action)
          with_tg_user_policy [:admin] do
            account = Teachbase::Bot::Account.find_by(tb_id: account_tb_id.to_i)
            return interface.sys.error.show unless account

            case action.to_sym
            when :edit
              interface.admin(account).menu.edit_account.show
            when :to_off, :to_on
              state = action.to_sym == :to_off ? false : true
              interface.sys.menu(disable_web_page_preview: true, mode: :none, text: I18n.t('confirm_action')).confirm_answer(:choice).show
              on_answer_confirmation(reaction: user_reaction.source) do
                account.update!(active: state)
              end
            end
          end
        end

        def update_account_setting(account_tb_id, param)
          with_tg_user_policy [:admin] do
            account = Teachbase::Bot::Account.find_by(tb_id: account_tb_id.to_i)
            return interface.sys.error.show unless account

            interface.sys.text.ask_value.show
            data = appshell.ask_answer(mode: :once)
            interface.sys.menu(disable_web_page_preview: true, mode: :none, text: I18n.t('confirm_action')).confirm_answer(:choice).show
            on_answer_confirmation(reaction: user_reaction.source) do
              result = 
                case param.to_sym
                when :tb_id, :curator_tg_id, :support_tg_id
                  data.source.to_i
                when :client_id, :client_secret, :name
                  data.source.to_s
                end
              account.update!(param.to_sym => result)
            end
          end
        end
      end
    end
  end
end