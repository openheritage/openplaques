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

end
