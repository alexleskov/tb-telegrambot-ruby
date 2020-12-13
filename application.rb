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
require 'timeout'

require './lib/app_configurator'
require './lib/emoji'
require './lib/emoji_aliaser'
require './lib/formatter'
require './lib/validator'
require './lib/decorators/decorators'
require './lib/message_responder'
require './lib/webhook_responder'
require './lib/message_sender'
require './lib/exceptions/teachbase_bot_exception'
require './lib/exceptions/account'
require './lib/app_shell'
require './lib/filer'
require './lib/breadcrumb'
require './lib/ai'
require './lib/interfaces/interfaces'
require './routers/routers/'
require './lib/webhooks/webhook_catcher'
require './lib/webhooks/base'
require './lib/webhooks/course_stat'
require './lib/attribute'
require './lib/respond'
require './lib/strategies/strategies'
require './lib/strategies/base'
require './lib/strategies/actions_list'
require './lib/strategies/standart_learning'
require './lib/strategies/demo_mode'
require './lib/strategies/methods/setting'
require './lib/strategies/methods/content'
require './lib/strategies/methods/course_session'
require './lib/strategies/methods/document'
require './lib/strategies/methods/find'
require './lib/strategies/methods/notify'
require './lib/strategies/methods/profile'
require './lib/strategies/methods/section'

require './models/bot_message'
require './models/tg_account_message'
require './models/tg_account'
require './models/setting'
require './models/user'
require './models/api_token'
require './models/account'
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
require './models/document'
require './models/answer'
require './models/comment'
require './models/cache_message'
require './models/category'
require './models/course_category'
require './models/command'

$app_config = AppConfigurator.instance
$app_config.configure
