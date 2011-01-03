class AddImageAndPhocoderAttsToImageUploads < ActiveRecord::Migration
  def self.up
    add_column :image_uploads, :phocoder_job_id, :integer
    add_column :image_uploads, :phocoder_input_id, :integer
    add_column :image_uploads, :phocoder_output_id, :integer
    add_column :image_uploads, :width, :integer
    add_column :image_uploads, :height, :integer
    add_column :image_uploads, :file_size, :integer
    add_column :image_uploads, :thumbnail, :string
    add_column :image_uploads, :parent_id, :integer
  end

  def self.down
    remove_column :image_uploads, :parent_id
    remove_column :image_uploads, :thumbnail
    remove_column :image_uploads, :file_size
    remove_column :image_uploads, :height
    remove_column :image_uploads, :width
    remove_column :image_uploads, :phocoder_output_id
    remove_column :image_uploads, :phocoder_input_id
    remove_column :image_uploads, :phocoder_job_id
  end
end
