require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TPS
  class Application < Rails::Application
    # config.time_zone = 'Paris'

    config.i18n.default_locale = :fr
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    config.autoload_paths += %W[#{config.root}/lib #{config.root}/app/validators #{config.root}/app/facades]
    config.assets.paths << Rails.root.join('app', 'assets', 'javascript')

    URL = if Rails.env.production?
            'https://opensimplif.modernisation.gouv.fr/'.freeze
          elsif Rails.env.staging?
            'https://tps-dev.apientreprise.fr/'.freeze # TODO: Change
          else
            'http://localhost:3000/'.freeze
          end
  end
end
