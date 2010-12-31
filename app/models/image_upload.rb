class ImageUpload < ActiveRecord::Base
  
  before_destroy :remove_local_file
  after_save :save_file
  
  def file=(new_file)
    self.filename = new_file.original_filename
    self.content_type = new_file.content_type
    @saved_file = new_file
  end
  
  
  def save_file
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
  
  
  
end
