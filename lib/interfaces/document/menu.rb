# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Document
        class Menu < Teachbase::Bot::Interfaces::Menu
          def list(documents, folder_id)
            @type = :menu_inline
            @mode = back_button ? :edit_msg : :none
            @text ||= "#{Emoji.t(:school_satchel)}<b>#{I18n.t('documents')}</b>"
            @disable_web_page_preview = :true
            @buttons = document_buttons(documents, folder_id)
            self
          end

          private

          def document_buttons(documents, folder_id)
            buttons_list = []
            documents.where(folder_id: folder_id).order(is_folder: :desc, built_at: :asc).each do |document|
              @entity = document
              document_button = document.is_folder ? build_folder_button : build_file_button
              buttons_list << document_button
            end
            InlineCallbackKeyboard.collect(buttons: buttons_list,
                                           back_button: back_button).raw
          end

          def build_folder_button
            InlineCallbackButton.g(button_sign: entity.title, emoji: entity.sign_emoji_by_type,
                                   callback_data: router.document(path: :entity, id: entity.tb_id).link)
          end

          def build_file_button
            return unless entity.url

            InlineUrlButton.g(button_sign: "#{entity.title} (#{entity.file_name})",
                              emoji: entity.sign_emoji_by_type, url: to_default_protocol(entity.url))
          end
        end
      end
    end
  end
end
