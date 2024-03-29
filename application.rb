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
require 'ostruct'
require 'rufus-scheduler'

require './lib/app_configurator'

require './lib/emoji'
require './lib/emoji_aliaser'

require './lib/editor_js/editor_js'
require './lib/formatter'
require './lib/validator'
require './lib/phrase'
require './lib/decorators/decorators'

require './lib/message_responder'
require './lib/webhook_responder'
require './lib/message_sender'

require './lib/exceptions/teachbase_bot_exception'
require './lib/exceptions/account'

require './lib/app_shell/app_shell'

require './lib/filer'
require './lib/breadcrumb'
require './lib/ai'
require './lib/helpers/notification'
require './lib/interfaces/interfaces'
require './router/router/'
require './lib/webhooks/webhook_catcher'
require './lib/webhooks/base'
require './lib/webhooks/course_stat'
require './lib/attribute'
require './lib/respond'

require './lib/strategies/strategies'
require './lib/strategies/actions_list'
require './lib/strategies/core'
require './lib/strategies/base'
require './lib/strategies/standart_learning'
require './lib/strategies/demo_mode'
require './lib/strategies/admin'

require './lib/strategies/admin/methods/account'

require './lib/strategies/base/methods/setting'
require './lib/strategies/base/methods/content'
require './lib/strategies/base/methods/course_session'
require './lib/strategies/base/methods/document'
require './lib/strategies/base/methods/find'
require './lib/strategies/base/methods/notify'
require './lib/strategies/base/methods/profile'
require './lib/strategies/base/methods/section'

require './lib/strategies/demo_mode/methods/setting'
require './lib/strategies/demo_mode/methods/content'
require './lib/strategies/demo_mode/methods/course_session'
require './lib/strategies/demo_mode/methods/document'
require './lib/strategies/demo_mode/methods/find'
require './lib/strategies/demo_mode/methods/notify'
require './lib/strategies/demo_mode/methods/profile'
require './lib/strategies/demo_mode/methods/section'

require './lib/strategies/standart_learning/methods/setting'
require './lib/strategies/standart_learning/methods/content'
require './lib/strategies/standart_learning/methods/course_session'
require './lib/strategies/standart_learning/methods/document'
require './lib/strategies/standart_learning/methods/find'
require './lib/strategies/standart_learning/methods/notify'
require './lib/strategies/standart_learning/methods/profile'
require './lib/strategies/standart_learning/methods/section'

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
$logger = $app_config.load_logger
