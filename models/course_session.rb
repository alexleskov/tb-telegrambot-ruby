require 'active_record'

module Teachbase
  module Bot
    class CourseSession < ActiveRecord::Base
      belongs_to :user
      has_many :sections, dependent: :destroy

      def list_state(state)
        order(name: :asc).where(complete_status: state.to_s)
      end
    end
  end
end
