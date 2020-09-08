# frozen_string_literal: true

require './models/profile'
require './models/course_session'
require './models/section'
require './models/material'
require './models/quiz'
require './models/scorm_package'
require './models/task'
require './models/attachment'
require './models/answer'
require './models/comment'
require './models/cache_message'
require './models/category'
require './models/course_category'
require './lib/attribute'

module Teachbase
  module Bot
    class DataLoaderController
      include Formatter

      MAX_RETRIES = 3

      attr_reader :appshell

      def initialize(appshell)
        @appshell = appshell
        @retries = 0
      end

      def update_data(data, mode = :with_create)
        return unless data

        call_data do
          db_entity(mode).update!(attrs_with_lms_data(data))
          db_entity
        end
      end

      def attrs_with_lms_data(data)
        raise "Cant find lms data. Given: '#{data}'." unless data

        Attribute.create(model_class.attribute_names, data, self.class::CUSTOM_ATTRS)
      end

      protected

      def call_data
        return unless appshell.access_mode == :with_api

        appshell.user
        yield
      rescue RuntimeError => e
        raise e if [400, 401, 402, 403, 404].include?(e.http_code)
          
        if (@retries += 1) <= MAX_RETRIES
          $logger.debug "#{e}\n#{I18n.t('retry')} №#{@retries}.."
          sleep(@retries)
          retry
        else
          appshell.logout
          $logger.debug "Unexpected error after retries: #{e}. code: #{e.http_code}"
          raise e
        end
      end
    end
  end
end
