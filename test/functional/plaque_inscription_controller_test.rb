require 'test_helper'

class PlaqueInscriptionControllerTest < ActionController::TestCase

  context "when not signed in as a user" do

    context "when attempting to view the edit plaque inscription page" do

      setup { get :edit, :plaque_id => plaques(:frankie_sheffield_plaque).id }

      should respond_with :success
      should render_template :edit
      should assign_to :plaque
      should assign_to :languages

    end

  end

  context "when signed in as a user" do

    setup { sign_in users(:quentin) }

    context "when viewing the edit plaque inscription page" do

      setup { get :edit, :plaque_id => plaques(:frankie_sheffield_plaque).id }

      should respond_with :success
      should render_template :edit
      should assign_to :plaque
      should assign_to :languages

    end

  end


end
