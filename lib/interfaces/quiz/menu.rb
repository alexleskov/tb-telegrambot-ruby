# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Quiz
        class Menu < Teachbase::Bot::InterfaceController
          def show
            answer.menu.back(text: "#{create_title(params)}\n#{Emoji.t(:baby)} <i>#{I18n.t('undefined_action')}</i>")
          end
        end
      end
    end
  end
end
