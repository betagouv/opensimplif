require_relative 'features'

if Rails.env.test?
  Fog.credentials_path = Rails.root.join('config/fog_credentials.test.yml')
else
  Fog.credentials_path = Rails.root.join('config/fog_credentials.yml')
end

CarrierWave.configure do |config|
  # These permissions will make dir and files available only to the user running
  # the servers
  config.permissions = 0o664
  config.directory_permissions = 0o775

  if Features.remote_storage && !Rails.env.test?
    config.fog_credentials = {provider: 'OpenStack'}
  end

  # This avoids uploaded files from saving to public/ and so
  # they will not be available for public (non-authenticated) downloading
  config.root = Rails.root

  config.cache_dir = "#{Rails.root}/uploads"

  config.fog_public = true

  config.fog_directory = if Rails.env.production?
                           'tps'
                         elsif Rails.env.development?
                           'test_local'
                         else
                           'tps_dev'
                         end
end
