require 'spec_helper'

describe "image_uploads/new.html.erb" do
  before(:each) do
    assign(:image_upload, stub_model(ImageUpload,
      :new_record? => true,
      :filename => "MyString"
    ))
  end

  it "renders new image_upload form" do
    render

    rendered.should have_selector("form", :action => image_uploads_path, :method => "post") do |form|
      form.should have_selector("input#image_upload_file", :name => "image_upload[file]")
    end
  end
end
