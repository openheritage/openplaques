require 'test_helper'

class PlaqueLocationControllerTest < ActionController::TestCase


  context "when signed in" do

    setup { sign_in users(:frankieroberto) }

    context "when viewing the page to edit a plaque's location" do

      setup { get :edit, :plaque_id => plaques(:frankie_sheffield_plaque).id }

      should respond_with :success
      should assign_to :plaque

    end

  end

end
