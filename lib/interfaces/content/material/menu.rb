# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Material
        class Menu < Teachbase::Bot::Interfaces::ContentItem::Menu
          DEFAULT_TIME_SPENT = 25

          def content
            @disable_web_page_preview = false
            @text = "#{create_title(title_params)}\n#{sign_entity_status}\n\n#{build_content}"
            super
          end

          private

          def build_approve_button
            super
            return unless entity.course_session.active? && entity.can_submit?

            time_spent = params[:approve_button][:time_spent] || DEFAULT_TIME_SPENT
            InlineCallbackButton.g(button_sign: I18n.t('viewed').to_s,
                                   callback_data: router.content(path: :track_time, id: entity.tb_id,
                                                                 p: [time: time_spent, sec_id: entity.section.id, cs_id: cs_tb_id]).link)
          end

          def build_content
            content_source = entity.build_source
            if url?(content_source)
              to_url_link(content_source, "#{Emoji.t(:link)} #{I18n.t('open').capitalize}: #{entity.name}")
            else
              content_source
            end
          end
        end
      end
    end
  end
end
