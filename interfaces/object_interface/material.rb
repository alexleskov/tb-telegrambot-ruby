# frozen_string_literal: true

module Teachbase
  module Bot
    module Interfaces
      module Material

        def print_material(material)
          buttons = material.action_buttons
          if answer.material.respond_to?(material.material_type)
            answer.material.public_send(material.material_type, material.build_source)
          else
            print_material_link(material)
          end
          menu_material_main(buttons: buttons) unless buttons.empty?
        rescue Telegram::Bot::Exceptions::ResponseError => e
          if e.error_code == 400
            print_material_link(material)
            menu_material_main(buttons: buttons) unless buttons.empty?
          else
            @logger.debug "Error: #{e}"
            answer.text.error
          end
        end

        def print_material_link(material)
          answer.material.url(link: material.source, link_name: "#{I18n.t('open').capitalize}: #{material.name}")
        end

        def menu_material_main(params)
          menu.create(buttons: params[:buttons], type: :menu_inline, disable_notification: true,
                      mode: params[:mode] || :none, text: I18n.t('start_menu_message'),
                      slices_count: params[:buttons].size)   
        end

      end
    end
  end
end