# frozen_string_literal: true

require 'active_record'

module Teachbase
  module Bot
    class Document < ActiveRecord::Base
      include Decorators::Document

      belongs_to :user
      belongs_to :account
    end
  end
end
