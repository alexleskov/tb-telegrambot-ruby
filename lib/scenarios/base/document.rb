# frozen_string_literal: true

module Teachbase
  module Bot
    module Scenarios
      module Base
        module Document
          def documents(folder_id = nil)
            documents_list = appshell.data_loader.user.documents.list
            return interface.sys.text.on_empty.show if documents_list.empty?

            current_folder_params =
            if folder_id
              folder = documents_list.find_by(tb_id: folder_id, is_folder: true)
              action = folder.folder_id ? router.document(path: :entity, id: folder.folder_id).link : router.main(path: :documents).link
              { text: "#{Emoji.t(folder.sign_emoji_by_type)}<b>#{folder.title}</b>",
                back_button: { mode: :custom, action: action, order: :ending }}
            else
              {}
            end

            interface.document.menu(current_folder_params).list(documents_list, folder_id).show
          end
        end
      end
    end
  end
end
