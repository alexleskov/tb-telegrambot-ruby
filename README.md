
# Telegram bot for Teachbase LMS

Telegram bot for studying in LMS Teachbase.Fight against your friends in the Battle mode or just learn your courses like rare man in Standart mode. Just try it! Must have user profile on Teachbase - https://teachbase.ru


## Installation

Set up gems:
```ruby
bundle install
```

Configurate connection for database:
Go `config/database.yml.sample` for sample configuration. Used PosrgreSQL on default.

Database install and migration:
```ruby
rake db:create
rake db:migrate
```

## Usage

### Bot configuration

Go `config/secrets.yml.sample` for sample configuration. Set up needed params:

`telegram_bot_token`
[Obtain a token](https://core.telegram.org/bots#6-botfather) for your bot.

`api_client_id, api_client_secret`
[Obtain client_id and client_secret](https://help.teachbase.ru/hc/ru/articles/360009569014#h_6144c047-c233-488c-9f0a-dcb7126e1513) from your organization's account on Teachbase LMS.

`api_account_id`
Account ID your organization's account on Teachbase LMS. Can obtain from support by the letter on help@teachbase.ru.

`lms_host: 'https://go.teachbase.ru'`
Default is https://go.teachbase.ru. Requires no changes for this param. Just use as set.

`token_expiration_time: '7200'`
Dafault user's token expiration time for `access_token`. Requires no changes for this param. Just use as set.

`rest_client: 'RestClient'`
Adapter for sending http-requests. Default is RestClient.

`encrypt_key`
Secret word for user password encryption.

`parse_mode: 'HTML'`
Parse mode for formatting text messages in Telegram API. More: https://core.telegram.org/bots/api#formatting-options
Used `'HTML'` on default.

### Bot starting

After installation and configuration you can start the telegram bot:
```ruby
bin/bot
```
If all is ok on starting console you will see message:
`"DEBUG -- : Starting telegram bot"