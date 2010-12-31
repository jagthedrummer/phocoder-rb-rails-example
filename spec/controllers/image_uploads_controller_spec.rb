require 'spec_helper'

describe ImageUploadsController do

  def mock_image_upload(stubs={})
    @mock_image_upload ||= mock_model(ImageUpload, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all image_uploads as @image_uploads" do
      ImageUpload.stub(:all) { [mock_image_upload] }
      get :index
      assigns(:image_uploads).should eq([mock_image_upload])
    end
  end

  describe "GET show" do
    it "assigns the requested image_upload as @image_upload" do
      ImageUpload.stub(:find).with("37") { mock_image_upload }
      get :show, :id => "37"
      assigns(:image_upload).should be(mock_image_upload)
    end
  end

  describe "GET new" do
    it "assigns a new image_upload as @image_upload" do
      ImageUpload.stub(:new) { mock_image_upload }
      get :new
      assigns(:image_upload).should be(mock_image_upload)
    end
  end

  describe "GET edit" do
    it "assigns the requested image_upload as @image_upload" do
      ImageUpload.stub(:find).with("37") { mock_image_upload }
      get :edit, :id => "37"
      assigns(:image_upload).should be(mock_image_upload)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created image_upload as @image_upload" do
        ImageUpload.stub(:new).with({'these' => 'params'}) { mock_image_upload(:save => true) }
        post :create, :image_upload => {'these' => 'params'}
        assigns(:image_upload).should be(mock_image_upload)
      end

      it "redirects to the created image_upload" do
        ImageUpload.stub(:new) { mock_image_upload(:save => true) }
        post :create, :image_upload => {}
        response.should redirect_to(image_upload_url(mock_image_upload))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved image_upload as @image_upload" do
        ImageUpload.stub(:new).with({'these' => 'params'}) { mock_image_upload(:save => false) }
        post :create, :image_upload => {'these' => 'params'}
        assigns(:image_upload).should be(mock_image_upload)
      end

      it "re-renders the 'new' template" do
        ImageUpload.stub(:new) { mock_image_upload(:save => false) }
        post :create, :image_upload => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested image_upload" do
        ImageUpload.should_receive(:find).with("37") { mock_image_upload }
        mock_image_upload.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :image_upload => {'these' => 'params'}
      end

      it "assigns the requested image_upload as @image_upload" do
        ImageUpload.stub(:find) { mock_image_upload(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:image_upload).should be(mock_image_upload)
      end

      it "redirects to the image_upload" do
        ImageUpload.stub(:find) { mock_image_upload(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(image_upload_url(mock_image_upload))
      end
    end

    describe "with invalid params" do
      it "assigns the image_upload as @image_upload" do
        ImageUpload.stub(:find) { mock_image_upload(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:image_upload).should be(mock_image_upload)
      end

      it "re-renders the 'edit' template" do
        ImageUpload.stub(:find) { mock_image_upload(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested image_upload" do
      ImageUpload.should_receive(:find).with("37") { mock_image_upload }
      mock_image_upload.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the image_uploads list" do
      ImageUpload.stub(:find) { mock_image_upload }
      delete :destroy, :id => "1"
      response.should redirect_to(image_uploads_url)
    end
  end

end
