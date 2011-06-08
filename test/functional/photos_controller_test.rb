require 'test_helper'

class PhotosControllerTest < ActionController::TestCase

  context "when viewing the index of photos" do

    setup { get :index }

    should respond_with :success
    should assign_to :photos
    should assign_to :photographer_count

  end

  context "when viewing the page for a particular photo" do

    setup { get :show, :id => photos(:frankie_photo).id }

    should respond_with :success
    should assign_to :photo

  end

  context "when signed in as a user" do

    setup { sign_in users(:frankieroberto) }

    context "when viewing the new photo page" do

      setup { get :new }

      should respond_with :success
      should assign_to :photo

    end

    context "when submitting a valid new photo" do
      setup do
        post :create, :photo => {:file_url => "http://test.com/image.png", :licence_id => licences(:ccby).id, :plaque_id => plaques(:frankie_sheffield_plaque).id }
      end

      should redirect_to("the page for the new photo") { photo_path(assigns(:photo)) }
    end

    context "when submitting an invalid new photo" do

      setup { post :create }

      should respond_with :success
      should assign_to :photo
      should render_template :new

    end

    context "when updating an existing photo with valid new details" do

      setup do
        @photo = photos(:frankie_photo)
        put :update, :id => @photo.id, :photo => {:file_url => @photo.file_url + "?test", :licence_id => @photo.licence_id, :plaque_id => @photo.plaque_id}
      end

      should redirect_to("the page for the photo") { photo_path(@photo.id) }

    end

  end

end
