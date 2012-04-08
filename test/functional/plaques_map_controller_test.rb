require 'test_helper'

class PlaquesMapControllerTest < ActionController::TestCase

  test "viewing the plaques map page" do
    get :show
    assert_response :success
    assert_template :show
  end


end
