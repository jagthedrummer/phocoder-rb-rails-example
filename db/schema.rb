# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110106224620) do

  create_table "image_uploads", :force => true do |t|
    t.string   "filename"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.integer  "phocoder_job_id"
    t.integer  "phocoder_input_id"
    t.integer  "phocoder_output_id"
    t.integer  "width"
    t.integer  "height"
    t.integer  "file_size"
    t.string   "thumbnail"
    t.integer  "parent_id"
    t.string   "status"
    t.string   "upload_host"
  end

end
