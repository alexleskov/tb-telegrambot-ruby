# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Quiz
        class Menu < Teachbase::Bot::InterfaceController
          def show
            params[:text] = "#{create_title(params)}\n#{Emoji.t(:baby)} <i>#{I18n.t('undefined_action')}</i>"
            super
          end

          private

# TODO: Waiting for url in source with jwt link
=begin
          def build_approve_button
            super
            InlineUrlButton.g(button_sign: I18n.t('open').capitalize,
                              url: to_default_protocol(entity.source),
                              emoji: :bar_chart)
          end
=end
        end
      end
    end
  end
end
