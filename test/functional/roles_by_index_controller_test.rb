require 'test_helper'

class RolesByIndexControllerTest < ActionController::TestCase

  context "when viewing the listing page for roles beginning with letter" do
    setup { get :show, :id => "a" }

    should respond_with :success
    should assign_to :roles
  end

  test "viewing the listing page for roles beginning with non-valid character" do
    get :show, :id => "|"
    assert_response :missing
  end


end
