# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class User
        class Text < Teachbase::Bot::InterfaceController
          def profile
            answer.text.send_out(entity.profile_info)
          end
        end
      end
    end
  end
end
