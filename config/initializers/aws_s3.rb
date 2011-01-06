require 'aws/s3'

config_path =  ::Rails.root.to_s + '/config/amazon_s3.yml'
Rails.logger.debug "---------------------------- reading config file!"
AWS_S3_CONFIG =  YAML.load(ERB.new(File.read(config_path)).result)[::Rails.env.to_s].symbolize_keys
AWS::S3::Base.establish_connection!(
  :access_key_id     => AWS_S3_CONFIG[:access_key_id],
  :secret_access_key => AWS_S3_CONFIG[:secret_access_key]
)

