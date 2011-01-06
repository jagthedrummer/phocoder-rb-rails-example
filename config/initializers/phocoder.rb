require 'phocoder'

config_path =  ::Rails.root.to_s + '/config/phocoder.yml'
Rails.logger.debug "---------------------------- reading config file!"
PHOCODER_CONFIG =  YAML.load(ERB.new(File.read(config_path)).result)[::Rails.env.to_s].symbolize_keys
Phocoder.api_key = PHOCODER_CONFIG[:api_key]