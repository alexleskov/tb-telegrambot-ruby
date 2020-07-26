# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class ScormPackage
        class Text < Teachbase::Bot::InterfaceController
          def show
            title
            link
          end

          def link
            answer.content.url(link: entity.source, link_name: "#{I18n.t('open').capitalize}: #{entity.name}")
          end

          def title
            answer.text.send_out(create_title(params), disable_notification: true)
          end
        end
      end
    end
  end
end
