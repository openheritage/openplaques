require 'test_helper'

class PlaquesLatestControllerTest < ActionController::TestCase

  context "when viewing the latest plaques page" do
    
    setup { get :show }
    
    should respond_with :success
    should assign_to :plaques
    should render_template :show    
    
  end

end
