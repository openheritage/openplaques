require 'test_helper'

class AllPlaquesControllerTest < ActionController::TestCase

  context "when viewing the all-plaques index page" do
    setup do
      get(:show)
    end
    
    should respond_with :success
    should assign_to :plaques
  end

  context "when attempting to view an XML representation of the all-plaques page" do
    setup do
      get(:show, {:format => "xml"})
    end
    
    should respond_with :moved_permanently
    should redirect_to("XML version of plaques page") { plaques_path(:format => "xml") }
  end

  context "when attempting to view a JSON representation of the all-plaques page" do
    setup do
      get(:show, {:format => "json"})
    end
    
    should respond_with :moved_permanently
    should redirect_to("JSON version of plaques page") { plaques_path(:format => "json") }
  end

  context "when attempting to view a KML representation of the all-plaques page" do
    setup do
      get(:show, {:format => "kml"})
    end
    
    should respond_with :moved_permanently
    should redirect_to("KML version of plaques page") { plaques_path(:format => "kml") }
  end


end
