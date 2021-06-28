# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Material
        class Menu < Teachbase::Bot::Interfaces::ContentItem::Menu
          DEFAULT_TIME_SPENT = 25

          def content
            @disable_web_page_preview = false
            super
          end

          private

          def build_approve_button
            return unless super

            router_parameters = { cs_id: entity.course_session.tb_id, sec_id: entity.section.id,
                                  time: approve_button[:time_spent] || DEFAULT_TIME_SPENT }
            InlineCallbackButton.g(button_sign: I18n.t('viewed').to_s, callback_data: router.g(:content, :track_time, id: entity.tb_id,
                                                                                                                      p: [router_parameters]).link)
          end

          def content_area
            content_source = entity.build_source
            url?(content_source) ? to_url_link(content_source, Phrase.new(entity).open_it) : content_source
          end
        end
      end
    end
  end
end
