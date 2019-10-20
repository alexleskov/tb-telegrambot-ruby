require 'active_record'

module Teachbase
  module Bot
    class Material < ActiveRecord::Base
      belongs_to :course_session, dependent: :destroy

    end
  end
end
