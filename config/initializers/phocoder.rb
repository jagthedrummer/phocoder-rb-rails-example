require 'phocoder'

config_path =  ::Rails.root.to_s + '/config/phocoder.yml'
Rails.logger.debug "---------------------------- reading config file!"
PHOCODER_CONFIG =  YAML.load(ERB.new(File.read(config_path)).result)[::Rails.env.to_s].symbolize_keys
Phocoder.api_key = PHOCODER_CONFIG[:api_key]
if PHOCODER_CONFIG[:base_url]
  Phocoder.base_url = PHOCODER_CONFIG[:base_url]
end

if PHOCODER_CONFIG[:callback_url]
  ImageUpload::CALLBACK_URL = PHOCODER_CONFIG[:callback_url]
end