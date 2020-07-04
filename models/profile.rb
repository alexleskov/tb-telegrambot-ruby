# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Profile < ActiveRecord::Base
      belongs_to :user, dependent: :destroy

      def cs_count_by(state)
        public_send("#{state}_courses_count").to_i
      end
    end
  end
end
