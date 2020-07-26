# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Material
        class Text < Teachbase::Bot::InterfaceController
          def show
            title
            if answer.content.respond_to?(entity.content_type)
              answer.content.public_send(entity.content_type, entity.build_source)
            else
              link
            end
          rescue Telegram::Bot::Exceptions::ResponseError => e
            if e.error_code == 400
              link
            else
              @logger.debug "Error: #{e}"
              answer.text.error
            end
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
