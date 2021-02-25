# frozen_string_literal: true

module Teachbase
  module Bot
    class Router
      class Main < Teachbase::Bot::Router::Route
        SOURCE = "main"
        START = "start"
        LOGOUT = "close"
        LOGIN = "sign_in"
        PASSWORD = "pswd"
        ACCOUNTS = "acc"
        DOCUMENTS = "docs"
        SEND_MESSAGE = "send_msg"
        FIND = "find"
        HELP = "help"
        ADMIN = "admin"

        def admin
          [ADMIN]
        end

        def start
          [START]
        end

        def logout
          [LOGOUT]
        end

        def password
          [PASSWORD]
        end

        def login
          [LOGIN]
        end

        def help
          [HELP]
        end

        def accounts
          [ACCOUNTS]
        end

        def send_message
          [SEND_MESSAGE]
        end

        def documents
          [DOCUMENTS]
        end

        def find
          [FIND]
        end
      end
    end
  end
end
