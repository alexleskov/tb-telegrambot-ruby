require 'active_record'

module Teachbase
  module Bot
    class Material < ActiveRecord::Base
      belongs_to :course_session, dependent: :destroy
      belongs_to :section, dependent: :destroy
      belongs_to :user, dependent: :destroy
    end
  end
end
