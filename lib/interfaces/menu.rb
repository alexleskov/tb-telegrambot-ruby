# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Menu < Teachbase::Bot::InterfaceController
        def show
          answer.menu.create(params).push
        end

        def hide
          answer.menu.hide(params).push
        end

        protected

        def init_commands
          answer.menu.command_list
        end
      end
    end
  end
end
