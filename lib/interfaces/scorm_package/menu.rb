# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class ScormPackage
        class Menu < Teachbase::Bot::InterfaceController
          def show
            params[:text] = create_title(params).to_s
            super
          end

          private

          def build_approve_button
            super
            InlineUrlButton.g(button_sign: I18n.t('open').capitalize,
                              url: to_default_protocol(entity.source),
                              emoji: :computer)
          end
        end
      end
    end
  end
end
