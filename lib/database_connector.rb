# frozen_string_literal: true

require 'active_record'
# require 'logger'

class DatabaseConnector
  class << self
    def establish_connection
      # ActiveRecord::Base.logger = Logger.new(active_record_logger_path)

      env = ENV["RAILS_ENV"] || 'development'
      configuration = YAML.safe_load(IO.read(database_config_path))[env]

      ActiveRecord::Base.establish_connection(configuration)
    end

    private

    def active_record_logger_path
      'log/ar_debug.log'
    end

    def database_config_path
      'config/database.yml'
    end
  end
end
