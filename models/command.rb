# require 'active_record'
require './lib/app_configurator'
require 'gemoji'

module Teachbase
  module Bot
    class Command # < ActiveRecord::Base
      attr_reader :key, :emoji, :text, :value

      def initialize(key, emoji)
        @key = key
        @emoji = emoji
        @text = I18n.t(key.to_s)
        @value = "#{emoji}#{text}"
      end
    end
  end
end
