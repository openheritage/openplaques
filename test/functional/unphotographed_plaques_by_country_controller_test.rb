require 'test_helper'

class UnphotographedPlaquesByCountryControllerTest < ActionController::TestCase

  context "when viewing the page for unphotographed plaques in a particular country" do
    
    setup { get :show, :country_id => countries(:gb).alpha2 }
    
    should respond_with :success
    should assign_to :plaques
    should render_template :show
    
  end

  context "when viewing the page for unphotographed plaques in a non-existant country" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) { get :show, :country_id => "xxxxx" }
    end    

  end  


end
