# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Material
        def print_material(material)
          print_material_title(material)
          buttons = material.action_buttons(approve_button: true)
          if answer.content.respond_to?(material.content_type)
            answer.content.public_send(material.content_type, material.build_source)
          else
            print_material_link(material)
          end
          menu_content_main(buttons: buttons) unless buttons.empty?
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.error_code == 400
            print_material_link(material)
            menu_content_main(buttons: buttons) unless buttons.empty?
          else
            @logger.debug "Error: #{e}"
            answer.text.error
          end
        end

        def print_material_link(material)
          answer.content.url(link: material.source, link_name: "#{I18n.t('open').capitalize}: #{material.name}")
        end

        def print_material_title(material)
          answer.text.send_out(create_title(object: material,
                                            stages: %i[contents title]), disable_notification: true)
        end
      end
    end
  end
end
