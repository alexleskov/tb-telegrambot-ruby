# frozen_string_literal: true

module Teachbase
  module Bot
    class Strategies
      class Document < Teachbase::Bot::Strategies
        def list_by(folder_id = nil)
          @folder_id = folder_id
          documents_list = appshell.data_loader.user.documents.list
          return interface.sys.text.on_empty.show if documents_list.empty?

          interface.document.menu(build_folder_button_params(documents_list)).list(documents_list, folder_id).show
        end

        private

        def build_folder_button_params(documents_list)
          if @folder_id
            folder = documents_list.find_by(tb_id: @folder_id, is_folder: true)
            action = folder.folder_id ? router.g(:document, :root, id: folder.folder_id).link : router.g(:main, :documents).link
            { text: "#{Emoji.t(folder.sign_emoji_by_type)}<b>#{folder.title}</b>",
              back_button: { mode: :custom, action: action, order: :ending } }
          else
            {}
            # TO DO: Fix document listing for searching and get it back
            # { back_button: { mode: :custom, action: router.g(:main, :find, p: [type: :document]).link,
            #                  button_sign: I18n.t('search'), emoji: :mag, order: :ending } }
          end
        end
      end
    end
  end
end
