# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Section
        class Menu < Teachbase::Bot::Interfaces::Menu
          def contents
            raise "Entity must be a Section" unless entity.is_a?(Teachbase::Bot::Section)

            @params[:type] = :menu_inline
            @params[:mode] ||= :none
            @params[:buttons] = contents_buttons
            @params[:text] = "#{create_title(object: entity.course_session,
                                             stages: %i[title], params: { cover_url: '' })} \u21B3 #{create_title(title_params)}"
            self
          end

          private

          def contents_buttons
            buttons_list = []
            contents_by_types = entity.contents_by_types
            contents_by_types.keys.each do |content_type|
              contents_by_types[content_type].each do |content|
                buttons_list << build_content_button(content, Teachbase::Bot::Section::OBJECTS_TYPES[content_type.to_sym])
              end
            end
            buttons_list = buttons_list.sort_by(&:position)
            buttons_list.unshift(build_addition_links_button) if entity.links_count.positive?
            InlineCallbackKeyboard.collect(buttons: buttons_list,
                                           back_button: back_button).raw
          end

          def build_content_button(content, type_by_section)
            router_parameters = { cs_id: content.course_session.tb_id, sec_id: content.section_id, type: type_by_section }
            InlineCallbackButton.g(button_sign: button_sign_by_content_type(type_by_section.to_s, content),
                                   callback_data: router.g(:content, :root, id: content.tb_id,
                                                                            p: [router_parameters]).link,
                                   position: content.position)
          end

          def build_addition_links_button
            InlineCallbackButton.g(callback_data: router.g(:section, :additions, id: entity.id, p: [cs_id: entity.course_session.tb_id]).link,
                                   button_sign: I18n.t('attachments').to_s, emoji: :package)
          end
        end
      end
    end
  end
end
