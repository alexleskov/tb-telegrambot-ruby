# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Quiz
        class Menu < Teachbase::Bot::InterfaceController
          def show
            answer.menu.custom_back(text: "#{create_title(params)}\n#{Emoji.t(:baby)} <i>#{I18n.t('undefined_action')}</i>",
                                    callback_data: "/sec#{entity.section.id}_cs#{cs_tb_id}")
          end
        end
      end
    end
  end
end