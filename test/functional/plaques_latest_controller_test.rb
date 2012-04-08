require 'test_helper'

class PlaquesLatestControllerTest < ActionController::TestCase

  test "viewing the latest plaques page" do

    get :show

    assert_response :success
    assert_not_nil assigns(:plaques)
    assert_template :show

  end

end
