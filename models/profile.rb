# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Profile < ActiveRecord::Base
      belongs_to :user
      belongs_to :account

      LINK_ATTRS = { "url" => "source", "label" => "title" }.freeze

      def cs_count_by(state)
        public_send("#{state}_courses_count").to_i
      end
    end
  end
end
