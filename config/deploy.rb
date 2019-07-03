# config valid only for current version of Capistrano
lock '~> 3.10.1'

def deploysecret(key)
  @deploy_secrets_yml ||= YAML.load_file('config/deploy-secrets.yml')[fetch(:stage).to_s]
  @deploy_secrets_yml.fetch(key.to_s, 'undefined')
end

set :rails_env, fetch(:stage)
set :rvm1_map_bins, -> { fetch(:rvm_map_bins).to_a.concat(%w[rake gem bundle ruby]).uniq }

set :application, 'consul'
set :full_app_name, deploysecret(:full_app_name)

set :server_name, deploysecret(:server_name)
set :repo_url, "https://www.gobiernodecanarias.net/aplicaciones/git/gobierno-abierto/ecociv/consul.git"
set :git_http_username, deploysecret(:git_http_username)
set :git_http_password, deploysecret(:git_http_password)
set :revision, `git rev-parse --short #{fetch(:branch)}`.strip

set :log_level, :info
set :pty, true
set :use_sudo, false

set :linked_files, %w{config/database.yml config/secrets.yml config/environments/production.rb}
set :linked_dirs, %w{log tmp public/system public/assets}

set :keep_releases, 5

set :local_user, ENV['USER']

set :puma_conf, "#{release_path}/config/puma/#{fetch(:rails_env)}.rb"

set :delayed_job_workers, 2
set :delayed_job_roles, :background

set(:config_files, %w(
  log_rotation
  database.yml
  secrets.yml
))

set :whenever_roles, -> { :app }

namespace :deploy do
  Rake::Task["delayed_job:default"].clear_actions
  Rake::Task["puma:smart_restart"].clear_actions

  before :starting, "rvm1:install:rvm"
  before :starting, "rvm1:install:ruby"
  before :starting, "install_bundler_gem"

  after :publishing, "setup_puma"

  after :published, "deploy:restart"
  before "deploy:restart", "puma:restart"
  before "deploy:restart", "delayed_job:restart"
  before "deploy:restart", "puma:start"

  after :finishing, 'deploy:cleanup'
  after :finished, "refresh_sitemap"
end

task :install_bundler_gem do
  on roles(:app) do
    within release_path do
      execute :rvm, fetch(:rvm1_ruby_version), "do", "gem install bundler"
    end
  end
end

task :refresh_sitemap do
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, 'sitemap:refresh:no_ping'
      end
    end
  end
end

desc "Create pid and socket folders needed by puma"
task :setup_puma do
  on roles(:app) do
    with rails_env: fetch(:rails_env) do
      execute "mkdir -p #{shared_path}/tmp/sockets; true"
      execute "mkdir -p #{shared_path}/tmp/pids; true"
    end
  end
end
