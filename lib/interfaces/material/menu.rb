# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Material
        class Menu < Teachbase::Bot::InterfaceController
          DEFAULT_TIME_SPENT = 25

          def show
            params[:text] = "#{create_title(params)}\n#{build_content}"
            super
          end

          private

          def build_approve_button
            super
            return unless entity.course_session.active? && entity.can_submit?

            time_spent = params[:approve_button][:time_spent] || DEFAULT_TIME_SPENT
            InlineCallbackButton.g(button_sign: I18n.t('viewed').to_s,
                                   callback_data: "approve_material_by_csid:#{cs_tb_id}_secid:#{entity.section.id}_objid:#{entity.tb_id}_time:#{time_spent}")
          end
        end
      end
    end
  end
end
