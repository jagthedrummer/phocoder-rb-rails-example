class ImageUpload < ActiveRecord::Base
  require 'aws/s3'
  require 'phocoder'
  before_destroy :remove_local_file,:remove_s3_file
  after_save :save_local_file
  
  has_many :thumbnails, :class_name=>"ImageUpload"
  belongs_to :parent, :class_name=>"ImageUpload"
  
  scope :top_level, where({:parent_id=>nil})
  
  THUMBNAILS = [
    {:label=>"small",:width=>100,:height=>100},
    {:label=>"medium",:width=>400,:height=>400},
  ]
  
  def file=(new_file)
    self.filename = new_file.original_filename
    self.content_type = new_file.content_type
    @saved_file = new_file
  end
  
  
  def save_local_file
    return if @saved_file.blank?
    FileUtils.mkdir_p local_dir
    FileUtils.cp @saved_file.tempfile.path, local_path
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
  
  #---------------------------------------------------------------
  #S3 stuff.s3.amazonaws.com
  #---------------------------------------------------------------
  
  attr_reader :bucket_name
  
  def s3_key
    File.join(resource_dir,filename)
  end
  
  def s3_url
    "http://#{s3_config[:bucket_name]}.s3.amazonaws.com/#{s3_key}"
  end
  
  def s3_config
    return @s3_config if !@s3_config.blank?
    config_path =  ::Rails.root.to_s + '/config/amazon_s3.yml'
    Rails.logger.debug "---------------------------- reading config file!"
    @s3_config =  YAML.load(ERB.new(File.read(config_path)).result)[::Rails.env.to_s].symbolize_keys
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
  
  #---------------------------------------------------------------
  # Phocoder stuff
  #---------------------------------------------------------------
  
  def phocoder_init
    config_path =  ::Rails.root.to_s + '/config/phocoder.yml'
    Rails.logger.debug "---------------------------- reading config file!"
    @phocoder_config =  YAML.load(ERB.new(File.read(config_path)).result)[::Rails.env.to_s].symbolize_keys
    Phocoder.api_key = @phocoder_config[:api_key]
  end
  
  
  def phocoder_params
    {:input => {:url => self.s3_url, :notifications=>[{:url=>"http://phocoderexample.chaos.webapeel.com/image_uploads/phocoder_update.json" }] },
      :thumbnails => THUMBNAILS.map{|thumb|
        thumb_filename = thumb[:label] + "_" + File.basename(self.filename,File.extname(self.filename)) + ".jpg" 
        base_url = "s3://#{s3_config[:bucket_name]}/#{self.resource_dir}/"
        thumb.merge({
          :filename=>thumb_filename,
          :base_url=>base_url,
          :notifications=>[{:url=>"http://phocoderexample.chaos.webapeel.com/image_uploads/phocoder_update.json" }]
        })
      }
    }
  end
  
  def phocode
    phocoder_init
    response = Phocoder::Job.create(phocoder_params)
    self.phocoder_input_id = response.body["job"]["inputs"].first["id"]
    self.phocoder_job_id = response.body["job"]["id"]
    self.save
    response.body["job"]["thumbnails"].each do |thumb_params|
      thumb = ImageUpload.new(
        :thumbnail=>thumb_params["label"],
        :filename=>thumb_params["filename"],
        :phocoder_output_id=>thumb_params["id"],
        :phocoder_job_id=>response.body["job"]["id"],
        :parent_id=>self.id
      )
      thumb.save
    end
  end
  
  def self.update_from_phocoder(params)
    if !params[:output].blank?
      iu = ImageUpload.find_by_phocoder_output_id params[:output][:id]
      img_params = params[:output]
    else
      iu = ImageUpload.find_by_phocoder_input_id params[:input][:id]
      img_params = params[:input]
    end
    iu.file_size = img_params[:file_size]
    iu.width = img_params[:width]
    iu.height = img_params[:height]
    iu.save
    iu
  end
  
  
end
