require 'test_helper'

class PlaquesControllerTest < ActionController::TestCase

  context "when viewing the index page for all plaques" do
    setup do
      get(:index)
    end
    
    should respond_with :success
    should render_template :index
    should assign_to :plaques
    should respond_with_content_type "text/html"
    
  end
  
  context "when viewing the XML feed of all plaques" do
    setup do
      get(:index, :format => "xml")
    end
    
    should respond_with :success
    should assign_to :plaques
    should respond_with_content_type "application/xml"
  end

  context "when viewing the JSON feed or all plaques" do
    setup do
      get(:index, :format => "json")
    end
    
    should respond_with :success
    should assign_to :plaques
    should respond_with_content_type "application/json"
  end  
    
  context "when viewing the new plaque page" do
    
    context "when not signed in" do

      setup do
        get(:new)
      end

      should respond_with :success
      should assign_to :plaque      
      should assign_to :user      
      
    end
    
    context "whilst signed in" do
      
      setup do
        sign_in users(:frankieroberto)
        get(:new)        
      end
      
      should respond_with :success
      should assign_to :plaque      
      
    end    
    
  end

  context "when viewing a plaque page" do
    setup do
      get(:show, {:id => plaques(:frankie_sheffield_plaque).id})
    end
    
    should respond_with :success
    should render_template :show
    should assign_to :plaque
    should respond_with_content_type "text/html"
    
  end
  
  context "when viewing a plaque's xml representation" do
    setup do
      get(:show, {:id => Plaque.first.id, :format => "xml"})
    end
    
    should respond_with :success
    should assign_to :plaque
    should respond_with_content_type "application/xml"
  end  

  context "when viewing a plaque's JSON representation" do
    setup do
      get(:show, {:id => plaques(:frankie_sheffield_plaque).id, :format => "json"})
      @plaque = ActiveSupport::JSON.decode(@response.body)
    end
    
    should respond_with :success
    should assign_to :plaque
    should respond_with_content_type "application/json"
    should "return a plaque object" do 
      assert_not_nil @plaque["plaque"]
    end
    should "return only only one object" do
      assert_equal @plaque.size, 1
    end
    should "include inscription" do
      assert @plaque["plaque"].has_key?("inscription")
    end
    
    should "include id" do
      assert @plaque["plaque"].has_key?("id")
    end

    should "include colour" do
      assert @plaque["plaque"].has_key?("colour")
    end

    should "include name of colour" do
      assert @plaque["plaque"]["colour"].has_key?("name")
    end

    should "include organisation" do
      assert @plaque["plaque"].has_key?("organisation")
    end

    should "include name of organisation" do
      assert @plaque["plaque"]["organisation"].has_key?("name")
    end


    should "not include parsed inscription" do
      assert !@plaque["plaque"].has_key?("parsed_inscription")
    end

    should "not include notes" do
      assert !@plaque["plaque"].has_key?("notes")
    end

    should "not include accuracy" do
      assert !@plaque["plaque"].has_key?("accuracy")
    end

    should "not include colour_id" do
      assert !@plaque["plaque"].has_key?("colour_id")
    end

  
  end
  
  context "when requesting a non-existant plaque" do
  
    should "raise a 'not found' error" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:show, {:id => "9999999999"})        
      end
    end
  end  


  context "when not signed in as user" do
  
    context "when submitting an invalid new plaque" do
      
      setup do
        post :create, :plaque => {}        
      end

      should assign_to :plaque
      should render_template :new
      
    end
    
  end
  
end
