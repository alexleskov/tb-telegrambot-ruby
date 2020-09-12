# frozen_string_literal: true

require './models/command'

module Teachbase
  module Bot
    class CommandList
      @sign_and_emoji = [:sign_in, Emoji.t(:rocket)],
                        [:sign_out, Emoji.t(:door)],
                        [:settings, Emoji.t(:wrench)],
                        [:user_profile, Emoji.t(:mortar_board)],
                        [:cs_list, Emoji.t(:books)],
                        [:update_profile_data, Emoji.t(:arrows_counterclockwise)],
                        [:ready, Emoji.t(:hand)],
                        [:more_actions, Emoji.t(:link)]
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
        raise "No such param: #{param}" unless %i[key emoji text value].include?(param)

        all.any? { |command| command.public_send(param).to_s == data.to_s }
      end

      def find_by(param, data)
        return unless command_by?(param, data)

        all.select { |command| command.public_send(param).to_s == data.to_s }.first
      end

      def show(key)
        find_by(:key, key).value
      end
    end
  end
end
