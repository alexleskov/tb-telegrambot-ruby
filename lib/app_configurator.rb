# frozen_string_literal: true

require 'logger'

require './lib/database_connector'

class AppConfigurator
  def initialize
    @load_config_file = IO.read('config/secrets.yml')
  end

  def configure
    setup_i18n
    setup_database
  end

  def load_token
    YAML.safe_load(@load_config_file)['telegram_bot_token']
  end

  def load_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end

  def load_encrypt_key
    YAML.safe_load(@load_config_file)['encrypt_key']
  end

  def load_parse_mode
    YAML.safe_load(@load_config_file)['parse_mode']
  end

  def rest_client
    YAML.safe_load(@load_config_file)['rest_client']
  end

  def lms_host
    YAML.safe_load(@load_config_file)['lms_host']
  end

  def client_id
    YAML.safe_load(@load_config_file)['api_client_id']
  end

  def client_secret
    YAML.safe_load(@load_config_file)['api_client_secret']
  end

  def account_id
    YAML.safe_load(@load_config_file)['api_account_id']
  end

  def token_expiration_time
    YAML.safe_load(@load_config_file)['token_expiration_time']
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales.yml']
    I18n.available_locales = %i[en ru]
    I18n.default_locale = :ru
    I18n.backend.load_translations
  end

  def setup_database
    DatabaseConnector.establish_connection
  end
end
