require 'test_helper'

class ExploreControllerTest < ActionController::TestCase


  test "should get the explore page" do

    get :show

    assert_response :success

  end

  test "should get a basic json view of the explore page" do

    get :show, :format => :json

    assert_response :success

  end

end
