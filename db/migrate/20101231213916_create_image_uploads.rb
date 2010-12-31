class CreateImageUploads < ActiveRecord::Migration
  def self.up
    create_table :image_uploads do |t|
      t.string :filename

      t.timestamps
    end
  end

  def self.down
    drop_table :image_uploads
  end
end
