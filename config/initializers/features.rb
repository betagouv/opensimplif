require 'yaml'
# this class manage features
# Features must be added in file config/initializers/features.yml :
# feature_name: true
# other_feature: false
#
# this file is templated by ansible for staging and production so don't forget to add your features in
# ansible config
class Features
  class << self
    if File.exist?(File.dirname(__FILE__) + '/features.yml')
      features_map = YAML.load_file(File.dirname(__FILE__) + '/features.yml')
      features_map&.each do |feature, is_active|
        define_method(feature.to_s) do
          is_active
        end
      end

      def method_missing(_method, *_args)
        false
      end

      def respond_to_missing?(method_name, include_private = false)
        super
      end
    end
  end
end
