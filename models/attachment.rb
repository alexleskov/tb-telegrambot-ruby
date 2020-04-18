require 'active_record'

module Teachbase
  module Bot
    class Attachment < ActiveRecord::Base
      belongs_to :material
      belongs_to :quiz
      belongs_to :task
      belongs_to :scorm_package
    end
  end
end
