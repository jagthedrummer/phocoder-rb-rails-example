require 'spec_helper'

describe "image_uploads/edit.html.erb" do
  before(:each) do
    @image_upload = assign(:image_upload, stub_model(ImageUpload,
      :new_record? => false,
      :filename => "MyString"
    ))
  end

  it "renders the edit image_upload form" do
    render

    rendered.should have_selector("form", :action => image_upload_path(@image_upload), :method => "post") do |form|
      form.should have_selector("input#image_upload_filename", :name => "image_upload[filename]")
    end
  end
end
