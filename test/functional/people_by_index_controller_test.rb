require 'test_helper'

class PeopleByIndexControllerTest < ActionController::TestCase

  context "when viewing an index page for people" do
    setup do
      get(:show, {:id => "c"})
    end

    should respond_with :success
    should assign_to :people
  end

  test "attempting to view an index page for a non A-Z letter" do
    get :show, :id => "_"
    assert_response(404)
  end

  test "attempting to view an index page for a two-character index" do
    get :show, :id => "ab"
    assert_response(404)
  end

  context "when attempting to view an index page with an uppercase letter" do
    setup do
      get(:show, {:id => "C"})
    end

    should respond_with :moved_permanently
    should redirect_to("lowercase version of letter") { people_by_index_url("c") }

  end


end
