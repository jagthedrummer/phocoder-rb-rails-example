require "spec_helper"

describe ImageUploadsController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/image_uploads" }.should route_to(:controller => "image_uploads", :action => "index")
    end

        it "recognizes and generates #new" do
      { :get => "/image_uploads/new" }.should route_to(:controller => "image_uploads", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/image_uploads/1" }.should route_to(:controller => "image_uploads", :action => "show", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/image_uploads" }.should route_to(:controller => "image_uploads", :action => "create")
    end


    it "recognizes and generates #destroy" do
      { :delete => "/image_uploads/1" }.should route_to(:controller => "image_uploads", :action => "destroy", :id => "1")
    end

  end
end
