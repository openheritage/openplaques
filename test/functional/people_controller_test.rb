require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  context "when viewing the people index page" do
    setup do
      get(:index)
    end
    should redirect_to("the 'people beginning with a' page") {people_by_index_path("a")}
  end

  context "when viewing a person page" do
    setup do
      get(:show, {:id => people(:frankie).id})
    end

    should respond_with :success
    should assign_to :person

  end

  test "requesting non-existant person" do
    get :show, :id => "99999"
    assert_response(404)
  end

  context "when signed in as a user" do

    setup { sign_in users(:frankieroberto) }

    context "when viewing the page to edit a person" do

      setup { get :edit, :id => people(:frankie).id }

      should respond_with :success
      should assign_to :person

    end

  end

end
