# frozen_string_literal: true

require './lib/scenarios/scenarios'
require './lib/authorizer'
require './lib/data_loaders/data_loaders'

module Teachbase
  module Bot
    class AppShell
      include Formatter
      include Validator

      ABORT_ACTION_COMMAND = %r{^/stop}.freeze

      attr_reader :controller,
                  :data_loader,
                  :settings,
                  :authorizer,
                  :authsession
      attr_accessor :access_mode

      def initialize(controller, access_mode = :with_api)
        @logger = AppConfigurator.new.load_logger
        @access_mode = access_mode
        raise "'#{controller}' is not Teachbase::Bot::Controller" unless controller.is_a?(Teachbase::Bot::Controller)

        @controller = controller
        @settings = controller.respond.msg_responder.settings
        @authorizer = Teachbase::Bot::Authorizer.new(self)
        @data_loader = Teachbase::Bot::DataLoaders.new(self)
        set_scenario
      end

      def user(mode = access_mode)
        @authsession = authorizer.call_authsession(mode)
        authorizer.user
      end

      def user_fullname(option = :string)
        user_db = authorizer.authsession? ? user(:without_api) : nil
        user_name = if user_db && [user_db.first_name, user_db.last_name].none?(nil)
                      [user_db.first_name, user_db.last_name]
                    else
                      controller.tg_user.user_fullname
                    end
        option == :string ? user_name.join(" ") : user_name
      end

      def authorization(mode = access_mode)
        user(mode)
        return unless authsession.is_a?(Teachbase::Bot::AuthSession)

        data_loader.user.profile
        authsession
      end

      def logout
        authorizer.unauthorize
      end

      def change_scenario(scenario_name)
        raise "No such scenario: '#{scenario_name}'" unless Teachbase::Bot::Scenarios::LIST.include?(scenario_name)

        settings.update!(scenario: scenario_name)
        controller.class.send(:include, to_constantize("Teachbase::Bot::Scenarios::#{to_camelize(scenario_name)}"))
      end

      def change_localization(lang)
        settings.update!(localization: lang)
        I18n.with_locale settings.localization.to_sym do
          controller.respond.reload_commands
        end
      end

      def request_data(validate_type)
        data = controller.take_data
        return if break_taking_data?(data)

        value = data.respond_to?(:text) ? data.text : data.file
        data if validation(validate_type, value)
      end

      def request_user_data
        controller.answer.text.ask_login
        user_login = request_data(:login).text
        raise unless user_login

        controller.answer.text.ask_password
        user_password = request_data(:password).text
        [user_login, user_password]
      end

      def ask_answer(params = {})
        params[:answer_type] ||= :none
        params[:mode] ||= :once
        params[:saving] ||= :perm
        case params[:mode]
        when :once
          request_data(params[:answer_type])
        when :bulk
          request_answer_bulk(params)
        end
      end

      def clear_cached_answers
        controller.tg_user.cache_messages.destroy_all
      end

      def cached_answers_texts
        controller.tg_user.cache_messages.texts
      end

      def cached_answers_files
        result = []
        files = controller.tg_user.cache_messages.files
        return result if files.empty?

        files.each do |file_id|
          result << { file: controller.filer.upload(file_id) }
        end
        result
      end

      def user_cached_answer
        "#{cached_answers_texts}\n
         #{Emoji.t(:bookmark_tabs)} #{I18n.t('attachments').capitalize}: #{cached_answers_files.size}"
      end

      private

      def request_answer_bulk(params)
        loop do
          user_answer = request_data(params[:answer_type])

          @logger.debug "user_answer: #{user_answer}"
          break if user_answer.nil? || (user_answer.respond_to?(:text) && break_taking_data?(user_answer.text))

          user_answer.save_message(params[:saving])
          controller.answer.menu.ready
        end
      end

      def break_taking_data?(msg)
        if msg.respond_to?(:text)
          result = !(msg.text =~ ABORT_ACTION_COMMAND).nil? || controller.respond.commands.command_by?(:value, msg.text)
          !!result
        elsif msg.nil?
          !msg
        end
        # Will be add something for files on else
      end

      def set_scenario
        change_scenario(settings.scenario)
      end
    end
  end
end
