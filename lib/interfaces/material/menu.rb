# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Material
        class Menu < Teachbase::Bot::InterfaceController
          def actions
            params.merge!(type: :menu_inline, disable_web_page_preview: true, disable_notification: true,
                          slices_count: 2, buttons: action_buttons)
            params[:text] ||= I18n.t('start_menu_message')
            params[:mode] ||= :none
            answer.menu.create(params)
          end

          private

          def build_approve_button(time_spent = 50)
            return unless params[:approve_button] && entity.course_session.active?

            InlineCallbackButton.g(button_sign: I18n.t('viewed').to_s,
                                   callback_data: "approve_material_by_csid:#{cs_tb_id}_secid:#{entity.section.id}_objid:#{entity.tb_id}_time:#{time_spent}",
                                   emoji: :white_check_mark)
          end
        end
      end
    end
  end
end