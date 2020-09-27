# frozen_string_literal: true

require 'telegram/bot'
require 'gemoji'
require 'async'
require 'encrypted_strings'
require 'sanitize'
require 'English'
require 'open-uri'
require 'singleton'
require 'sapcai'

require './lib/app_configurator'
require './lib/emoji'
require './lib/emoji_aliaser'
require './lib/formatter'
require './lib/validator'
require './lib/decorators/decorators'
require './lib/message_responder'
require './lib/message_sender'
require './lib/exceptions/teachbase_bot_exception'
require './lib/exceptions/account'

$app_config = AppConfigurator.instance
$app_config.configure
