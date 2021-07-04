# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Admin
        class Menu < Teachbase::Bot::Interfaces::Core::Menu
          ACTIONS = %w[edit to_on to_off].freeze

          def main
            @params[:type] = :menu
            @params[:slices_count] = 2
            @params[:text] ||= "#{Emoji.t(:wrench)} <b>#{I18n.t('admin_menu_message')}</b>"
            @params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[accounts_manager new_account starting]).raw
            self
          end

          def account
            @params[:type] = :menu_inline
            @params[:slices_count] = 2
            @params[:buttons] = account_action_buttons
            @params[:mode] ||= :none
            @params[:text] ||= "<b>#{entity.title}</b>"
            self
          end

          def edit_account
            @params[:type] = :menu_inline
            @params[:slices_count] = 3
            @params[:buttons] = account_edit_action_buttons
            @params[:mode] ||= :edit_msg
            @params[:text] ||= "#{entity.main_info}\n\n<b>#{I18n.t('edit')}:</b>"
            self
          end

          private

          def account_edit_action_buttons
            buttons_actions = []
            all_account_attrs = Teachbase::Bot::Account::MAIN_ATTRS + Teachbase::Bot::Account::ADDIT_ATTRS
            all_account_attrs.each do |account_param|
              buttons_actions << router.g(:admin, :root, p: [acc_id: entity.tb_id, param: account_param]).link
            end
            InlineCallbackKeyboard.g(buttons_signs: all_account_attrs, buttons_actions: buttons_actions,
                                     back_button: back_button).raw
          end

          def account_action_buttons
            buttons_actions = []
            actions_list = ACTIONS.dup
            entity.active ? actions_list.delete("to_on") : actions_list.delete("to_off")
            actions_list.each { |action| buttons_actions << router.g(:admin, :root, p: [acc_id: entity.tb_id, type: action.to_s]).link }
            InlineCallbackKeyboard.g(buttons_signs: to_i18n(actions_list), buttons_actions: buttons_actions,
                                     back_button: back_button).raw
          end
        end
      end
    end
  end
end
