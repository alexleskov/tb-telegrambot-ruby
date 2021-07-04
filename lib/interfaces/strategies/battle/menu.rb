# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Battle
        class Menu < Teachbase::Bot::Interfaces::Base::Menu
          def after_auth
            @params[:type] = :menu
            @params[:slices_count] = 2
            @params[:text] ||= I18n.t('undefined_action').to_s
            @params[:buttons] = TextCommandKeyboard.g(commands: init_commands, buttons_signs: %i[sign_out]).raw
            self
          end
        end
      end
    end
  end
end
