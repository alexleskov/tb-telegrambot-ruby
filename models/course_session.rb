# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class CourseSession < ActiveRecord::Base
      include Viewers::Course

      belongs_to :user
      has_many :sections, dependent: :destroy
      has_many :materials, dependent: :destroy

      def list_state(state)
        order(name: :asc).where(complete_status: state.to_s)
      end

      def active?
        complete_status == "active"
      end
    end
  end
end
