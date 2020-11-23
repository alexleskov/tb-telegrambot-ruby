# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock "~> 3.14.1"

server '188.246.233.53', port: 5000

set :puma_threads,    [4, 16]
set :puma_workers,    0
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

set :application, "tb-telegrambot"
set :repo_url, "https://github.com/alexleskov/tb-telegrambot-ruby.git"

ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

set :deploy_to, "/home/deplo/tb-telegrambot"

append :linked_files, "config/database.yml", "config/secrets.yml"
append :linked_dirs, "log", "tmp"

# Default value for default_env is {}
set :default_env, RAILS_ENV: fetch(:stage)


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

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :start, :make_dirs
end

before "deploy:restart_bot", "puma:start", "db:migrate"
after "deploy:finishing", "deploy:restart_bot", "puma:restart"
