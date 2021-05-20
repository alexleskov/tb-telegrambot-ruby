# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Admin
        class Account < Teachbase::Bot::Strategies
          attr_reader :tb_id

          def initialize(params, controller)
            super(controller)
            @tb_id = params[:tb_id]
          end

          def list
            with_tg_user_policy [:admin] do
              accounts_list = Teachbase::Bot::Account.all.order(name: :asc)
              interface.sys.menu.decline.show
              data = appshell.request_user_account_data(accounts_list, %i[statuses tb_ids])
              return interface.admin.menu(text: I18n.t('declined')).main.show unless data

              account = Teachbase::Bot::Account.find_by(tb_id: data.to_i)
              return interface.sys.on_empty.show unless account

              interface.admin.menu.main.show
              interface.admin(account).menu.account.show
            end
          end

          def add_new
            with_tg_user_policy [:admin] do
              account_data = request_attributes_values
              return interface.sys.text.error.show unless (Teachbase::Bot::Account::MAIN_ATTRS - account_data.keys).empty?

              with_check_avaliable(account_data[:tb_id], account_data[:client_id], account_data[:client_secret]) do
                Teachbase::Bot::Account.create!(account_data)
              end
            end
          end

          def action(action)
            with_tg_user_policy [:admin] do
              account = Teachbase::Bot::Account.find_by(tb_id: tb_id.to_i)
              return interface.sys.error.show unless account

              case action.to_sym
              when :edit
                interface.admin(account).menu.edit_account.show
              when :to_off, :to_on
                interface.sys.menu(disable_web_page_preview: true, mode: :none, text: I18n.t('confirm_action')).confirm_answer(:choice).show
                on_answer_confirmation(reaction: user_reaction.source) do
                  account.update!(active: action.to_sym != :to_off)
                end
              end
            end
          end

          def update(setting)
            with_tg_user_policy [:admin] do
              account = Teachbase::Bot::Account.find_by(tb_id: tb_id.to_i)
              return interface.sys.error.show unless account && Teachbase::Bot::Account.include_attribute?(setting)

              interface.sys.text.ask_value.show
              data = appshell.ask_answer(mode: :once)
              interface.sys.menu(disable_web_page_preview: true, mode: :none, text: I18n.t('confirm_action')).confirm_answer(:choice).show
              on_answer_confirmation(reaction: user_reaction.source) do
                value = %i[tb_id curator_tg_id support_tg_id].include?(setting.to_sym) ? data.source.to_i : data.source.to_s
                account.public_send("#{setting}=", value)
                with_check_avaliable(account.tb_id, account.client_id, account.client_secret) do
                  account.save!
                end
              end
            end
          end

          private

          def with_check_avaliable(account_tb_id, client_id, client_secret)
            ping_result = ping(account_tb_id, client_id, client_secret)
            raise "No ping" unless ping_result

            begin
              yield
            rescue ActiveRecord => e
              interface.sys.text.on_error(e).show
            end
            interface.sys.text.update_status(:success).show
          end

          def request_attributes_values
            data = {}
            Teachbase::Bot::Account::MAIN_ATTRS.each do |attribute|
              interface.sys.text.ask_value(" <b>#{attribute}</b>").show
              value = appshell.ask_answer(mode: :once).source
              data[attribute.to_sym] = attribute == :tb_id ? value.to_i : value.to_s
            end
            data
          end

          def ping(account_tb_id, client_id, client_secret)
            result = appshell.authorizer.ping(account_id: account_tb_id, client_id: client_id, client_secret: client_secret)
            return if result.is_a?(RestClient::Unauthorized)

            result
          end
        end
      end
    end
  end
end
