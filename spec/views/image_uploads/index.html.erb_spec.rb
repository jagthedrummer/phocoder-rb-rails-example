require 'spec_helper'

describe "image_uploads/index.html.erb" do
  before(:each) do
    assign(:image_uploads, [
      stub_model(ImageUpload,
        :filename => "Filename"
      ),
      stub_model(ImageUpload,
        :filename => "Filename"
      )
    ])
  end

  it "renders a list of image_uploads" do
    render
    rendered.should have_selector("tr>td", :content => "Filename".to_s, :count => 2)
  end
end
