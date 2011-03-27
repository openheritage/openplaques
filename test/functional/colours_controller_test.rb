require 'test_helper'

class ColoursControllerTest < ActionController::TestCase

  context "when viewing the index page" do
    
    setup do
      get :index
    end

    should respond_with :success
    should assign_to :colours
  end


  context "when viewing a colour page" do
    setup do
      get :show, {:id => colours(:blue).name}
    end
    
    should respond_with :success
    should assign_to :colour
    
  end
  
  context "when viewing a legacy colour URL identified by an id" do

    setup do
      @colour = colours(:blue)
      get(:show, {:id => @colour.id})
    end

    should respond_with :moved_permanently
    should redirect_to("color page") {colour_path(@colour.name)}
  end
  
  context "when requesting a non-existant colour" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:show, {:id => "blueygreenorange"})
      end
    end
  end

  context "when vieing the new colour page" do
    
    context "when signed in" do
      
      setup do
        sign_in users(:frankieroberto)
        get :new
      end
      
      should respond_with :success
      should assign_to :colour
      
    end
    
  end

  context "when vieing the edit colour page" do
    
    context "when signed in" do
      
      setup do
        sign_in users(:frankieroberto)
        get :edit, :id => colours(:blue).name
      end
      
      should respond_with :success
      should assign_to :colour
      
    end
    
  end

end
