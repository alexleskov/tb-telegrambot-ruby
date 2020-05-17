# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Profile < ActiveRecord::Base
      belongs_to :user, dependent: :destroy
    end
  end
end
