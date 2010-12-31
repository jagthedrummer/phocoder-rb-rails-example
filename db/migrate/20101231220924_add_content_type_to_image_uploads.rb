class AddContentTypeToImageUploads < ActiveRecord::Migration
  def self.up
    add_column :image_uploads, :content_type, :string
  end

  def self.down
    remove_column :image_uploads, :content_type
  end
end
