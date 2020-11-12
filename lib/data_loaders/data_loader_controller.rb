# frozen_string_literal: true

require './models/auth_session'
require './models/profile'
require './models/course_session'
require './models/section'
require './models/material'
require './models/quiz'
require './models/scorm_package'
require './models/task'
require './models/poll'
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

      def current_account
        appshell.authsession.account
      end

      protected

      def call_data
        return unless appshell.access_mode == :with_api

        appshell.user
        yield
      rescue RuntimeError, TeachbaseBotException => e
        if e.respond_to?(:http_code) && !(400..404).include?(e.http_code)
          $logger.debug "Unexpected error: #{e}. Data: #{e.response}"
          # relogin_after_error(e)
          raise e
        else
          raise e
        end
      end

      def relogin_after_error(error)
        appshell.logout
        appshell.controller.interface.sys.menu(text: to_text_by_exceiption_code(error)).sign_in_again.show
      end
    end
  end
end
