require 'spec_helper'

describe ImageUpload do
  
  before(:each) do
    @attr = {
      :file => Rack::Test::UploadedFile.new(fixture_path + '/big_eye_tiny.jpg', 'image/jpeg') 
    }
  end
  
  
  it "should get the right file name" do
    iu = ImageUpload.new(@attr)
    iu.filename.should == "big_eye_tiny.jpg"
  end
  
  it "should read AWS::S3 config" do
    iu = ImageUpload.new(@attr)
    iu.s3_config[:bucket_name].should == "test.phocoder-rb-rails-example.webapeel.com"
  end
  
  
  it "should save the file to a local storage location" do
    iu = ImageUpload.new(@attr)
    iu.save
    expected_local_path = File.join(RAILS_ROOT,'public','ImageUpload',iu.id.to_s,iu.filename)
    iu.local_path.should == expected_local_path
    iu.local_url.should == "/ImageUpload/#{iu.id}/#{iu.filename}"
    File.exists?(expected_local_path).should be_true
    iu.destroy
    File.exists?(expected_local_path).should_not be_true
  end
  
  it "should save the file to an AWS S3 storage location" do
    iu = ImageUpload.new(@attr)
    iu.save
    expected_local_path = File.join(RAILS_ROOT,'public','ImageUpload',iu.id.to_s,iu.filename)
    iu.local_path.should == expected_local_path
    iu.local_url.should == "/ImageUpload/#{iu.id}/#{iu.filename}"
    File.exists?(expected_local_path).should be_true
    #should not be on S3 yet
    bucket = iu.s3_config[:bucket_name]
    key = iu.s3_key
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should raise_error(Exception)
    #now store in S3
    iu.save_s3_file
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should_not raise_error(Exception)
    
    iu.destroy
    lambda{
      o = AWS::S3::S3Object.find(key,bucket)
    }.should raise_error(Exception)
    File.exists?(expected_local_path).should_not be_true
  end
  
  
  
  
end
