#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/application"
Rails.application.require_environment!

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  Rails.logger.auto_flushing = true
  Rails.logger.info "This daemon is still running at #{Time.now}.\n"
  
  while(ImageUpload.top_level.local(%x{hostname}.strip).count > 0) do
    image = ImageUpload.top_level.local(%x{hostname}.strip).first
    image.save_s3_file
    image.phocode
  end
  
  sleep 5
end