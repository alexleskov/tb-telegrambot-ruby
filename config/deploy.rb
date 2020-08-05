# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

set :application, "tb-telegrambot"
set :repo_url, "https://github.com/alexleskov/tb-telegrambot-ruby.git"

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/home/deplo/tb-telegrambot"

append :linked_files, "config/database.yml", "config/secrets.yml"
append :linked_dirs, "log", "tmp"

# Default value for default_env is {}
set :default_env, { RAILS_ENV: fetch(:stage) }

namespace :db do
  task :create do
    on roles(:all) do
      within release_path do
        execute :rake, "db:create"
      end
    end
  end

  task :migrate do
    on roles(:all) do
      within release_path do
        execute :rake, "db:migrate"
      end
    end
  end
end

namespace :deploy do
  task :start_bot do
    on roles(:all) do
      execute :sudo, :monit, 'start tb_bot'
    end
  end

  task :stop_bot do
    on roles(:all) do
      execute :sudo, :monit, 'stop tb_bot'
    end
  end

  task :restart_bot do
    on roles(:all) do
      execute :sudo, :monit, 'restart tb_bot'
    end
  end
end

before "deploy:restart_bot", "db:migrate"
after "deploy:finishing", "deploy:restart_bot"
