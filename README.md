
# Telegram bot for Teachbase LMS

Telegram bot for studying in LMS Teachbase.Fight against your friends in the Battle mode or just learn your courses like rare man in Standart mode. Just try it! Must have user profile on Teachbase - https://teachbase.ru


## Installation

Set up gems:
```bush
bundle install
```

Configurate connection for database:

Go `config/database.yml.sample` for sample configuration. Used PosrgreSQL on default.

Database install and migration:

```bush
rake db:create
rake db:migrate
```

## Usage

### Bot configuration

Go `config/secrets.yml.sample` for sample configuration. Set up all needed params.


[Obtain a token](https://core.telegram.org/bots#6-botfather) for your bot:

`telegram_bot_token`


[Obtain client_id and client_secret](https://help.teachbase.ru/hc/ru/articles/360009569014#h_6144c047-c233-488c-9f0a-dcb7126e1513) from your organization's account on Teachbase LMS:

`api_client_id, api_client_secret`


Organization's Account ID on Teachbase LMS. Can be obtain by request on help@teachbase.ru:

`api_account_id`


Default host is https://go.teachbase.ru. Requires no changes for this param. Just use as set:

`lms_host: 'https://go.teachbase.ru'`


Dafault user's token expiration time for `access_token`. Requires no changes. Just use as set:

`token_expiration_time: '7200'`


Adapter for http-requests sender. Default is RestClient:

`rest_client: 'RestClient'`


Secret word for user password encryption:

`encrypt_key`


Parse mode for formatting text messages in Telegram API. More: https://core.telegram.org/bots/api#formatting-options
Used to `'HTML'` on default.

`parse_mode: 'HTML'`


### Bot starting

After installation and configuration you can start the telegram bot:

```bush
bin/bot
```

IRB console:

```bush
bin/console
```


### Deploy

Setup ssh config for production server
Push all changes
and run:

```bash
bundle exec cap production deploy
```

Another commands:

```bash
bundle exec cap production deploy:restart_bot
bundle exec cap production deploy:start_bot
bundle exec cap production deploy:stop_bot
```

