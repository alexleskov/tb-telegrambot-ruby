# frozen_string_literal: true

module Teachbase
  module Bot
    class Router
      class Admin < Teachbase::Bot::Router::Route
        SOURCE = "admin"
        NEW = "new"
        ACCOUNT = "acc"

        def root
          [SOURCE]
        end

        def new_account
          root + [NEW, ACCOUNT]
        end
      end
    end
  end
end
