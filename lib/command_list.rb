require './models/command'
require './lib/app_configurator'
require 'gemoji'

module Teachbase
  module Bot
    class CommandList
      attr_reader :all

      def initialize
        @all = []
        create
      end

      def create
        sign_emoji = [:signin, Emoji.find_by_alias('rocket').raw],
                    [:settings, Emoji.find_by_alias('wrench').raw],
                    [:show_profile_state, Emoji.find_by_alias('mortar_board').raw]
        sign_emoji.each { |data| all << Teachbase::Bot::Command.new(data[0], data[1]) }
        all
        raise "'CommandList' not created" if all.empty?
      end

      def command_by?(param, data)
        raise "No such param: #{param}" if ![:key,:emoji,:text,:value].include?(param)
        all.any? { |command| command.public_send(param) == data}
      end

      def find_by(param, data)
        return unless command_by?(param, data)

        command = all.select { |command| command.public_send(param) == data}
        command.first
      end

      def show(key)
        find_by(:key, key).value
      end
    end
  end
end
