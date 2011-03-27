require 'test_helper'

class HomepageControllerTest < ActionController::TestCase

  context "when viewing the homepage" do
    setup do
      get :index
    end
    
    should respond_with :success
    should assign_to :recent_photos
    should assign_to :geolocated_plaques_count
    should assign_to :plaques_count
    should assign_to :photographed_plaques_count
    should assign_to :coloured_plaques_count            
    should render_template :index
    
  end


end
