require 'test_helper'

class PlaquesMapControllerTest < ActionController::TestCase

  context "when viewing the plaques map page" do
    
    setup { get :show }
    
    should respond_with :success
    should assign_to :plaques
    should render_template :show
    
  end


end
