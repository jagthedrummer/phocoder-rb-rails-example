require 'spec_helper'

describe "image_uploads/show.html.erb" do
  before(:each) do
    @image_upload = assign(:image_upload, stub_model(ImageUpload,
      :filename => "Filename"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("Filename".to_s)
  end
end
