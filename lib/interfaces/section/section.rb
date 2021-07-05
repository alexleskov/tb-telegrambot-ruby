# frozen_string_literal: true

module Teachbase
  module Bot
    class Interfaces
      class Section < Teachbase::Bot::Interfaces::Core
        CHOOSING_BUTTONS = %i[show_all find_by_query_num].freeze
      end
    end
  end
end
