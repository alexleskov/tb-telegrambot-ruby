# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Document < Teachbase::Bot::Strategies
        def list_by(folder_id = nil, menu_mode = :none)
          documents_list = appshell.data_loader.user.documents.list
          return interface.sys.text.on_empty.show if documents_list.empty?

          parent_folder = folder_id ? documents_list.find_by(tb_id: folder_id, is_folder: true) : nil
          documents_in_folder = documents_list.where(folder_id: folder_id).order(is_folder: :desc, built_at: :asc)

          interface.document.menu(build_back_button_params(parent_folder, folder_id).merge!(mode: menu_mode.to_sym))
                   .list(documents_in_folder, parent_folder).show
        end

        private

        def build_back_button_params(parent_folder, folder_id)
          if parent_folder
            action = parent_folder.folder_id ? router.g(:document, :root, id: parent_folder.folder_id).link : router.g(:main, :documents).link
            { text: "#{Emoji.t(parent_folder.sign_emoji_by_type)}<b>#{parent_folder.title}</b>#{build_link_on_current_folder(folder_id)}",
              back_button: { mode: :custom, action: action, order: :ending } }
          else
            { back_button: { mode: :custom, action: router.g(:main, :find, p: [type: :document]).link,
                             button_sign: I18n.t('search'), emoji: :mag, order: :ending } }
          end
        end

        def build_link_on_current_folder(folder_id)
          return "" unless folder_id

          " — #{router.g(:document, :root, id: folder_id).link}"
        end
      end
    end
  end
end
