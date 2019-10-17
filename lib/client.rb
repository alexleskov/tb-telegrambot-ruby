require './models/user'

module Teachbase
  module Bot
    class Client
      attr_reader :commands

      def initialize
        @commands = { signin: "#{Emoji.find_by_alias('rocket').raw}#{I18n.t('signin')}",
                      settings: "#{Emoji.find_by_alias('wrench').raw}#{I18n.t('settings')}" }
      end
    end
  end
end
