require 'active_record'

module Teachbase
  module Bot
    class Material < ActiveRecord::Base
      include Viewers::Material

      belongs_to :course_session
      belongs_to :section
      belongs_to :user
    end
  end
end
