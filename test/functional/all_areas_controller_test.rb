require 'test_helper'

class AllAreasControllerTest < ActionController::TestCase

  context "when viewing a list of all areas" do
    
    context "as a json feed" do
      setup do
        get(:show, :format => :json)
      end
    
      should respond_with :success
      should assign_to :areas
    end
    
    context "starting with 'Lo'" do

      setup do
        get(:show, :format => :json, :term => "Lo")
      end      

      should respond_with :success
      should assign_to :areas
      
    end
    
  end
end