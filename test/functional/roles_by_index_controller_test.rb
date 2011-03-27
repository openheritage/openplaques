require 'test_helper'

class RolesByIndexControllerTest < ActionController::TestCase

  context "when viewing the listing page for roles beginning with letter" do
    setup { get :show, :id => "a" }

    should respond_with :success
    should assign_to :roles
  end

  context "when viewing the listing page for roles beginning with non-valid character" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) { get :show, :id => "|" }
    end
    
  end
    
  
end
