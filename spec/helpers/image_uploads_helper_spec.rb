require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the ImageUploadsHelper. For example:
#
# describe ImageUploadsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ImageUploadsHelper do
  
  before(:each) do
    @image_upload = Factory(:image_upload,:phocoder_job_id=>1,:phocoder_input_id=>1)
  end

  describe "phocoder_thumbnail frunctions" do
    
    it "should return a waiting image when thumbs have not been generated" do
      tag = helper.phocoder_thumbnail(@image_upload,"small")
      tag.should match /waiting.gif/
    end
    
    it "should return an error div if the thumbnails type is not known" do
      tag = helper.phocoder_thumbnail(@image_upload,"funky-thumb")
      tag.should match /error/
    end
    
    
    it "should return an image tag if the thumbnail is there" do
      @small_thumbnail = Factory(:image_upload,:filename=>"small-test.jpg",:thumbnail=>"small",:parent_id=>@image_upload.id)
      tag = helper.phocoder_thumbnail(@image_upload,"small")
      tag.should match /small-test.jpg/
      tag.should match Regexp.new(@small_thumbnail.s3_url)
    end
    
  end #describe "phocoder_thumbnail frunctions" do

end
