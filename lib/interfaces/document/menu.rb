# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Document
        class Menu < Teachbase::Bot::Interfaces::Menu
          def list(documents, parent_folder = nil)
            @params[:type] = :menu_inline
            @params[:mode] ||= back_button && parent_folder ? :edit_msg : :none
            @params[:text] ||= Phrase.documents
            @params[:disable_web_page_preview] = true
            @params[:buttons] = document_buttons(documents)
            self
          end

          private

          def document_buttons(documents)
            buttons_list = []
            documents.each do |document|
              @entity = document
              document_button = document.is_folder ? build_folder_button : build_file_button
              buttons_list << document_button
            end
            InlineCallbackKeyboard.collect(buttons: buttons_list, back_button: back_button).raw
          end

          def build_folder_button
            InlineCallbackButton.g(button_sign: entity.title, emoji: entity.sign_emoji_by_type,
                                   callback_data: router.g(:document, :root, id: entity.tb_id).link)
          end

          def build_file_button
            return unless entity.url

            InlineUrlButton.g(button_sign: "#{entity.title} #{"(#{entity.file_type.upcase})" if entity.file_type}",
                              emoji: entity.sign_emoji_by_type, url: to_default_protocol(entity.url))
          end
        end
      end
    end
  end
end
