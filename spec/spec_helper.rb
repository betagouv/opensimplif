# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

ENV['RAILS_ENV'] ||= 'test'

if ENV['COV']
  require 'simplecov'
  SimpleCov.start 'rails'
  puts "required simplecov"
end

require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'capybara/rspec'
require 'database_cleaner'
require 'webmock/rspec'
require 'shoulda-matchers'
require 'devise'
require 'factory_girl'

require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist
Capybara.ignore_hidden_elements = false
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: true, port: 44_678 + ENV['TEST_ENV_NUMBER'].to_i, phantomjs_options: ['--proxy-type=none'], timeout: 180)
end

ActiveSupport::Deprecation.silenced = true

Capybara.default_max_wait_time = 1

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }
Dir[Rails.root.join('spec/factories/**/*.rb')].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

VCR.configure do |c|
  c.ignore_localhost = true
  c.hook_into :webmock
  c.cassette_library_dir = 'spec/fixtures/cassettes'
  c.configure_rspec_metadata!
end

DatabaseCleaner.strategy = :truncation

SIADETOKEN = :valid_token unless defined? SIADETOKEN
BROWSER.value = Browser.new('Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.2; Win64; x64; Trident/6.0)')

include Warden::Test::Helpers

include SmartListing::Helper
include SmartListing::Helper::ControllerExtensions

module SmartListing
  module Helper
    def view_context
      'mock'
    end
  end
end

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.filter_run_excluding disable: true
  config.color = true
  config.infer_spec_type_from_file_location!
  config.tty = true

  config.include Shoulda::Matchers::ActiveRecord, type: :model
  config.include Shoulda::Matchers::ActiveModel, type: :model
  config.include Shoulda::Matchers::Independent, type: :model

  config.use_transactional_fixtures = false

  config.infer_base_class_for_anonymous_controllers = false

  config.filter_run :show_in_doc => true if ENV['APIPIE_RECORD']

  config.order = 'random'

  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view

  config.include FactoryGirl::Syntax::Methods

  config.before(:each) do
    allow_any_instance_of(PieceJustificativeUploader).to receive(:generate_secure_token).and_return("3dbb3535-5388-4a37-bc2d-778327b9f997")
    allow_any_instance_of(ProcedureLogoUploader).to receive(:generate_secure_token).and_return("3dbb3535-5388-4a37-bc2d-778327b9f998")
    allow_any_instance_of(CerfaUploader).to receive(:generate_secure_token).and_return("3dbb3535-5388-4a37-bc2d-778327b9f999")
  end

  config.before(:all) {
    Warden.test_mode!

    if Features.remote_storage
      VCR.use_cassette("ovh_storage_init") do
        CarrierWave.configure do |config|
          config.fog_credentials = {provider: 'OpenStack'}
        end
      end
    end
  }

  RSpec::Matchers.define :have_same_attributes_as do |expected|
    match do |actual|
      ignored = [:id, :procedure_id, :updated_at, :created_at]
      actual.attributes.with_indifferent_access.except(*ignored) == expected.attributes.with_indifferent_access.except(*ignored)
    end
  end
end