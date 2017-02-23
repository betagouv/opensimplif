require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv' # for rbenv support. (http://rbenv.org)
# require 'mina/rvm'    # for rvm support. (http://rvm.io)

# Basic settings:
#   domain       - The hostname to SSH to.
#   deploy_to    - Path to deploy into.
#   repository   - Git repo to clone from. (needed by mina/git)
#   branch       - Branch name to deploy. (needed by mina/git)

ENV['to'] ||= "opensimplif"
raise "Bad to=#{+ENV['to']}" unless ["opensimplif"].include?(ENV['to'])
raise "missing domain, run with 'rake deploy domain=IP_SERVER'" if ENV['domain'].nil?

set :domain, ENV['domain']
set :repository, 'https://github.com/XjulI1/opensimplif.git'
set :port, 2200

if ENV['branch'].nil?
  set :branch, 'master'
else
  set :branch, ENV['branch']
end
set :deploy_to, '/var/www/opensimplif'
set :user, 'opensimplif' # Username in the server to SSH to.
appname = 'opensimplif'

print "Deploy to #{ENV['to']} environment branch #{ENV['branch']} \n"

set :rails_env, "production"

# For system-wide RVM install.
#   set :rvm_path, '/usr/local/rvm/bin/rvm'

# Manually create these paths in shared/ (eg: shared/config/database.yml) in your server.
# They will be linked in the 'deploy:link_shared_paths' step.
set :shared_paths, [
                     'log',
                     'bin',
                     'uploads',
                     'tmp/pids',
                     'tmp/cache',
                     'tmp/sockets',
                     'public/system',
                     'public/uploads',
                     'config/database.yml',
                     "config/fog_credentials.yml",
                     'config/initializers/secret_token.rb',
                     'config/initializers/features.yml',
                     "config/environments/#{rails_env}.rb",
                     "config/initializers/token.rb",
                     "config/initializers/urls.rb",
                     "config/initializers/super_admin.rb",
                     "config/unicorn.rb",
                     "config/initializers/raven.rb",
                     "config/locales/dynamics/fr.yml",
                     'config/france_connect.yml',
                     'config/initializers/mailjet.rb',
                     'config/initializers/storage_url.rb',
                     'app/views/root/landing.html.haml',
                     'app/views/layouts/_google_analytics.html',
                     'app/views/cgu/index.html.haml'
                 ]


set :rbenv_path, "/usr/local/rbenv/bin/rbenv"

# Optional settings:
#   set :user, 'foobar'    # Username in the server to SSH to.
#   set :port, '30000'     # SSH port number.
set :forward_agent, true # SSH forward_agent.

# This task is the environment that is loaded for most commands, such as
# `mina deploy` or `mina rake`.
task :setup => :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/bin"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/bin"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/pids"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/pids"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/cache"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/cache"]

  queue! %[mkdir -p "#{deploy_to}/shared/tmp/sockets"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/tmp/sockets"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/system"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/system"]

  queue! %[mkdir -p "#{deploy_to}/shared/public/uploads"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/public/uploads"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[mkdir -p "#{deploy_to}/shared/app"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/app"]

  queue! %[mkdir -p "#{deploy_to}/shared/views/cgu"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/views/cgu"]

  queue! %[mkdir -p "#{deploy_to}/shared/views/layouts"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/views/layouts"]

  queue! %[mkdir -p "#{deploy_to}/shared/config/locales/dynamics"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config/locales/dynamics"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue %[echo "-----> Be sure to edit 'shared/config/database.yml'."]

  queue! %[touch "#{deploy_to}/shared/environments/production.rb"]
  queue %[echo "-----> Be sure to edit 'shared/environments/production.rb'."]

  queue! %[touch "#{deploy_to}/shared/environments/staging.rb"]
  queue %[echo "-----> Be sure to edit 'shared/environments/staging.rb'."]
end

desc "Deploys the current version to the server."
task :deploy => :environment do
  queue 'export PATH=$PATH:/usr/local/rbenv/bin:/usr/local/rbenv/shims'
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'rails:assets_precompile'

    to :launch do
      queue "/etc/init.d/#{user} upgrade "

      queue "cd #{deploy_to}/#{current_path}/"
      queue "bundle exec rake db:seed RAILS_ENV=#{rails_env}"
      queue %[echo "-----> Rake Seeding Completed."]
    end
  end
end
# For help in making your deploy script, see the Mina documentation:
#
#  - http://nadarei.co/mina
#  - http://nadarei.co/mina/tasks
#  - http://nadarei.co/mina/settings
#  - http://nadarei.co/mina/helpers
