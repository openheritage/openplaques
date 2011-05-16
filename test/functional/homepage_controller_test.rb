require 'test_helper'

class HomepageControllerTest < ActionController::TestCase

  context "when viewing the homepage" do
    setup do
      get :index
    end
    
    should respond_with :success
    should assign_to :plaques_count
    should render_template :index
    
  end


end
