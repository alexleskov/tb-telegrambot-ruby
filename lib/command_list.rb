require './models/command'
require './lib/app_configurator'
require 'gemoji'

module Teachbase
  module Bot
    class CommandList

      @sign_and_emoji = [:signin, Emoji.find_by_alias('rocket').raw],
                        [:sign_out, Emoji.find_by_alias('door').raw],
                        [:settings, Emoji.find_by_alias('wrench').raw],
                        [:show_profile_state, Emoji.find_by_alias('mortar_board').raw],
                        [:course_list_l1, Emoji.find_by_alias('books').raw],
                        [:update_profile_data, Emoji.find_by_alias('arrows_counterclockwise').raw]
      class << self
        attr_reader :sign_and_emoji
      end

      attr_reader :all

      def initialize
        @all = []
        create
      end

      def create
        Teachbase::Bot::CommandList.sign_and_emoji.each do |data|
          all << Teachbase::Bot::Command.new(data[0], data[1])
        end
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
