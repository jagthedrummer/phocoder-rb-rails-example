class ImageUpload < ActiveRecord::Base
  require 'aws/s3'
  before_destroy :remove_local_file,:remove_s3_file
  after_save :save_local_file
  
  def file=(new_file)
    self.filename = new_file.original_filename
    self.content_type = new_file.content_type
    @saved_file = new_file
  end
  
  
  def save_local_file
    return if @saved_file.blank?
    FileUtils.mkdir_p local_dir
    FileUtils.cp @saved_file.path, local_path
  end
  
  def remove_local_file
    if File.exists? local_path
      FileUtils.rm local_path
      FileUtils.rmdir local_dir
    end
  end
    
  def resource_dir
    File.join(self.class.name,id.to_s)
  end
  
  def local_dir
    File.join(Rails.root,'public',resource_dir)
  end

  def local_path
    File.join(local_dir,filename)
  end
  
  def local_url
    File.join("/",resource_dir,filename)
  end
  
  #S3 stuff
  attr_reader :bucket_name
  
  def s3_key
    File.join(resource_dir,filename)
  end
  
  def s3_config
    return @s3_config if !@s3_config.blank?
    config_path =  RAILS_ROOT + '/config/amazon_s3.yml'
    @s3_config =  YAML.load(ERB.new(File.read(config_path)).result)[RAILS_ENV].symbolize_keys
    AWS::S3::Base.establish_connection!(
      :access_key_id     => @s3_config[:access_key_id],
      :secret_access_key => @s3_config[:secret_access_key]
    )
    @s3_config
  end
  
  def save_s3_file
    AWS::S3::S3Object.store(
      s3_key, 
      open(local_path), 
      s3_config[:bucket_name],
      :access => :public_read
    )
  end
  
  def remove_s3_file
    AWS::S3::S3Object.delete s3_key, s3_config[:bucket_name]
  end
  
  
end
