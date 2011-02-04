class ImageUpload < ActiveRecord::Base
  
  
  before_destroy :destroy_thumbnails,:remove_local_file,:remove_s3_file
  after_save :save_local_file,:save_s3_file #,:phocode
  
  has_many :thumbnails, :class_name=>"ImageUpload",:foreign_key => "parent_id"
  belongs_to :parent, :class_name=>"ImageUpload",:foreign_key => "parent_id"
  
  scope :top_level, where({:parent_id=>nil})
  scope :local, lambda {|host| where(:upload_host => host,:status=>"local") }
  THUMBNAILS = [
    {:label=>"small",:width=>100,:height=>100 },
    {:label=>"medium",:width=>400,:height=>400, :frame=>{ :width=>20, :color=>'003' } },
    
    {:label=>"preserve-square",:width=>200,:height=>200,:aspect_mode=>"preserve" , :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"stretch-square",:width=>200,:height=>200,:aspect_mode=>"stretch", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"crop-square",:width=>200,:height=>200,:aspect_mode=>"crop", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"pad-square",:width=>200,:height=>200,:aspect_mode=>"pad", :frame=>{ :width=>10, :color=>'300' } },
    
    {:label=>"preserve-portrait",:width=>100,:height=>200,:aspect_mode=>"preserve", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"stretch-portrait",:width=>100,:height=>200,:aspect_mode=>"stretch", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"crop-portrait",:width=>100,:height=>200,:aspect_mode=>"crop", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"pad-portrait",:width=>100,:height=>200,:aspect_mode=>"pad", :frame=>{ :width=>10, :color=>'300' } },
    
    {:label=>"preserve-landscape",:width=>200,:height=>100,:aspect_mode=>"preserve", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"stretch-landscape",:width=>200,:height=>100,:aspect_mode=>"stretch", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"crop-landscape",:width=>200,:height=>100,:aspect_mode=>"crop", :frame=>{ :width=>10, :color=>'300' } },
    {:label=>"pad-landscape",:width=>200,:height=>100,:aspect_mode=>"pad", :frame=>{ :width=>10, :color=>'300' } }
    
  ]
  
  
  def callback_url
    CALLBACK_URL
  end
  
  def destroy_thumbnails
    self.thumbnails.each do |thumb|
      thumb.destroy
    end
  end
  
  def self.thumbnail_attributes_for(thumbnail = "small")
    atts = THUMBNAILS.select{|atts| atts[:label] == thumbnail }
    atts.first
  end
  
  def thumbnail_for(thumbnail_name)
    self.thumbnails.find_by_thumbnail(thumbnail_name)
  end
  
  def file=(new_file)
    self.filename = new_file.original_filename
    self.content_type = new_file.content_type
    @saved_file = new_file
  end
  
  
  def save_local_file
    return if @saved_file.blank?
    FileUtils.mkdir_p local_dir
    FileUtils.cp @saved_file.tempfile.path, local_path
    self.status = "local"
    self.upload_host = %x{hostname}.strip
    @saved_file = nil
    @saved_a_new_file = true
    self.save
  end
  
  def remove_local_file
    if local_path and File.exists? local_path
      FileUtils.rm local_path
      FileUtils.rmdir local_dir
    end
  end
    
  def resource_dir
    File.join(self.class.name, parent_id.blank? ? id.to_s : parent_id.to_s )
  end
  
  def local_dir
    File.join(::Rails.root,'public',resource_dir)
  end

  def local_path
    filename.blank? ? nil : File.join(local_dir,filename)
  end
  
  def local_url
    filename.blank? ? nil : File.join("/",resource_dir,filename)
  end
  
  
  # Sanitizes a filename.
  def filename=(new_name)
    write_attribute :filename, sanitize_filename(new_name)
  end
  
  def sanitize_filename(filename)
    return unless filename
    returning filename.strip do |name|
      # NOTE: File.basename doesn't work right with Windows paths on Unix
      # get only the filename, not the whole path
      name.gsub! /^.*(\\|\/)/, ''
      
      # Finally, replace all non alphanumeric, underscore or periods with underscore
      name.gsub! /[^A-Za-z0-9\.\-]/, '_'
    end
  end
  
  #---------------------------------------------------------------
  #S3 stuff.s3.amazonaws.com
  #---------------------------------------------------------------
  
  attr_reader :bucket_name
  
  def s3_key
    filename.blank? ? nil : File.join(resource_dir,filename)
  end
  
  def s3_url
    "http://#{s3_config[:bucket_name]}.s3.amazonaws.com/#{s3_key}"
  end
  
  def s3_config
    AWS_S3_CONFIG
#    return @s3_config if !@s3_config.blank?
#    config_path =  ::Rails.root.to_s + '/config/amazon_s3.yml'
#    Rails.logger.debug "---------------------------- reading config file!"
#    @s3_config =  YAML.load(ERB.new(File.read(config_path)).result)[::Rails.env.to_s].symbolize_keys
#    AWS::S3::Base.establish_connection!(
#      :access_key_id     => @s3_config[:access_key_id],
#      :secret_access_key => @s3_config[:secret_access_key]
#    )
#    @s3_config
  end
  
  def save_s3_file
    #this is a dirty hack to see what happens when we add save_s3_file and phocode to the after_save routine
    return if !@saved_a_new_file
    @saved_a_new_file = false
    AWS::S3::S3Object.store(
      s3_key, 
      open(local_path), 
      s3_config[:bucket_name],
      :access => :public_read
    )
    self.status = "s3"
    self.save
    self.phocode
  end
  
  def remove_s3_file
    AWS::S3::S3Object.delete s3_key, s3_config[:bucket_name]
  rescue Exception => e
    #this probably means that the file never made it to S3
  end
  
  #---------------------------------------------------------------
  # Phocoder stuff
  #---------------------------------------------------------------
  
 
  def phocoder_params
    {:input => {:url => self.s3_url, :notifications=>[{:url=>callback_url }] },
      :thumbnails => THUMBNAILS.map{|thumb|
        thumb_filename = thumb[:label] + "_" + File.basename(self.filename,File.extname(self.filename)) + ".jpg" 
        base_url = "s3://#{s3_config[:bucket_name]}/#{self.resource_dir}/"
        thumb.merge({
          :filename=>thumb_filename,
          :base_url=>base_url,
          :notifications=>[{:url=>callback_url }]
        })
      }
    }
  end
  
  def phocode
    
    if self.thumbnails.count >= THUMBNAILS.count
      raise "This item already has thumbnails!"
      return
    end
        
    return if @phocoding
    @phocoding = true
    
    Rails.logger.debug "trying to phocode for #{Phocoder.base_url}"
    Rails.logger.debug "callback url = #{callback_url}"
    response = Phocoder::Job.create(phocoder_params)
    self.phocoder_input_id = response.body["job"]["inputs"].first["id"]
    self.phocoder_job_id = response.body["job"]["id"]
    self.status = "phocoding"
    self.save #false need to do save(false) here if we're calling phocode on after_save
    response.body["job"]["thumbnails"].each do |thumb_params|
      thumb = ImageUpload.new(
        :thumbnail=>thumb_params["label"],
        :filename=>thumb_params["filename"],
        :phocoder_output_id=>thumb_params["id"],
        :phocoder_job_id=>response.body["job"]["id"],
        :parent_id=>self.id,
        :status => "phocoding"
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
    iu.status = "ready"
    iu.save
    iu
  end
  
  
end
