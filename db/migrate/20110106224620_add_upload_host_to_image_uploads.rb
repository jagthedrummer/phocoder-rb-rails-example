class AddUploadHostToImageUploads < ActiveRecord::Migration
  def self.up
    add_column :image_uploads, :upload_host, :string
  end

  def self.down
    remove_column :image_uploads, :upload_host
  end
end
