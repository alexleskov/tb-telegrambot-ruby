# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class StandartLearning
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def after_auth
            params.merge!(type: :menu, slices_count: 2)
            params[:text] ||= I18n.t('start_menu_message').to_s
            params[:buttons] = TextCommandKeyboard.g(commands: init_commands,
                                                     buttons_signs: %i[cs_list user_profile settings more_actions accounts sign_out]).raw
            answer.menu.create(params)
          end
        end
      end
    end
  end
end
