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

  should "get a 404 when requesting non-existant person" do

    assert_raises(ActiveRecord::RecordNotFound) do
      get(:show, {:id => "99999"})
    end
  end

end
