require 'logger'

require './lib/database_connector'

class AppConfigurator
  def configure
    setup_i18n
    setup_database
  end

  def get_token
    YAML.safe_load(IO.read('config/secrets.yml'))['telegram_bot_token']
  end

  def get_api_client_id
    YAML.safe_load(IO.read('config/secrets.yml'))['api_client_id']
  end

  def get_api_client_secret
    YAML.safe_load(IO.read('config/secrets.yml'))['api_client_secret']
  end

  def get_api_accountid
    YAML.safe_load(IO.read('config/secrets.yml'))['api_accountid']
  end

  def get_logger
    Logger.new(STDOUT, Logger::DEBUG)
  end

  def get_encrypt_key
    YAML.safe_load(IO.read('config/secrets.yml'))['encrypt_key']
  end

  private

  def setup_i18n
    I18n.load_path = Dir['config/locales.yml']
    I18n.locale = :ru
    I18n.backend.load_translations
  end

  def setup_database
    DatabaseConnector.establish_connection
  end
end
