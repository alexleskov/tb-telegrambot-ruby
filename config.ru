# frozen_string_literal: true

require_relative 'application'
require './lib/api_server'

use Rack::Reloader
run Teachbase::Bot::ApiServer.new
