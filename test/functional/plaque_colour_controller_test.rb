require 'test_helper'

class PlaqueColourControllerTest < ActionController::TestCase

  context "when not signed in as a user" do

    context "when attempting to view the edit plaque colour page" do
    
      setup { get :edit, :plaque_id => plaques(:frankie_sheffield_plaque).id }
    
      should respond_with :success
      should render_template :edit
      should assign_to :plaque
    
    end

  end

  context "when signed in as a user" do
    
    setup { sign_in users(:quentin) }
    
    context "when viewing the edit plaque colour page" do
      
      setup { get :edit, :plaque_id => plaques(:frankie_sheffield_plaque).id }
      
      should respond_with :success
      should render_template :edit
      should assign_to :plaque
      
    end    
    
  end


end
