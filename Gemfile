source 'https://rubygems.org'

ruby '2.3.1'

gem 'rails', '~> 5.0.3'

gem 'redis'

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'turbolinks', '~> 2.5'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Enable deep clone of active record models
gem 'deep_cloneable', '~> 2.2.1'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn'

gem 'active_model_serializers'
gem 'bootstrap-sass', '~> 3.3.5'
gem 'haml-rails'
gem 'will_paginate-bootstrap'

# Decorators
gem 'draper', '~> 3.0.0.pre1'
gem 'unicode_utils'

# Gestion des comptes utilisateurs
gem 'devise'
gem 'openid_connect'

gem 'rest-client'

gem 'clamav-client', require: 'clamav/client'

gem 'carrierwave', '~> 0.11.2'
gem 'fog'
gem 'fog-openstack'

gem 'pg'
gem 'scenic'

gem 'leaflet-draw-rails'
gem 'leaflet-markercluster-rails', '~> 0.7.0'
gem 'leaflet-rails'
gem 'rgeo-geojson'

gem 'bootstrap-datepicker-rails'

gem 'chartkick'

gem 'logstasher'

gem 'font-awesome-rails'

gem 'hashie'

gem 'mailjet'

gem 'smart_listing'

gem 'bootstrap-wysihtml5-rails', '~> 0.3.3.8'

gem 'as_csv'
gem 'spreadsheet_architect'

gem 'apipie-rails'
gem 'maruku' # for Markdown support in apipie

gem 'openstack'

gem 'browser'

group :test do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'guard'
  gem 'launchy'
  gem 'poltergeist'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', require: false
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webmock'
  # gem 'guard-rspec', require: false
  gem 'guard-livereload', '~> 2.4', require: false
  gem 'rails-controller-testing'
  gem 'vcr'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views

  gem 'rack-handlers'
  gem 'web-console'
  gem 'xray-rails'
end

group :development, :test do
  # gem 'terminal-notifier'
  # gem 'terminal-notifier-guard'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry-byebug'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-commands-rspec'
  gem 'rspec-rails', '~> 3.0'

  gem 'railroady'

  gem 'rubocop', require: false
  gem 'rubocop-checkstyle_formatter', require: false
  gem 'rubocop-rspec', require: false

  gem 'parallel_tests', '~> 2.10'

  gem 'brakeman', require: false

  # Deploy
  gem 'mina', ref: '343a7', git: 'https://github.com/mina-deploy/mina.git'
end

group :production, :staging do
  gem 'sentry-raven'
end
