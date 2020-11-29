# frozen_string_literal: true

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

      def db_entity(mode = :with_create)
        if mode == :with_create
          model_class.find_or_create_by!(tb_id: tb_id, user_id: appshell.user.id, account_id: appshell.current_account.id)
        else
          model_class.find_by!(tb_id: tb_id, user_id: appshell.user.id, account_id: appshell.current_account.id)
        end
      end

      protected

      def call_data
        return unless appshell.access_mode == :with_api

        appshell.user
        yield
      rescue RuntimeError, TeachbaseBotException => e
        if e.respond_to?(:http_code) && !(400..404).include?(e.http_code)
          $logger.debug "Unexpected error: #{e}. Data: #{e.response}"
          raise e
        else
          raise e
        end
      end
    end
  end
end
