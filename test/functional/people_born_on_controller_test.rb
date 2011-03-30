require 'test_helper'

class PeopleBornOnControllerTest < ActionController::TestCase

  context "when viewing the index page" do
    
    setup { get :index }
    
    should respond_with :success
    should assign_to :counts    
    
  end
  
  context "when viewing the page for people born in a particular year" do
    
    setup { get :show, :id => "1984"}
    
    should respond_with :success
    should assign_to :people
    should assign_to :year
    
  end
  
end
