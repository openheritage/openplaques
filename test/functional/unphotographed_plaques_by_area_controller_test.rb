require 'test_helper'

class UnphotographedPlaquesByAreaControllerTest < ActionController::TestCase

  should "get London" do
    get(:show, {:area_id => areas(:london).slug, :country_id => countries(:gb).alpha2})
    assert_response :success
  end


end
