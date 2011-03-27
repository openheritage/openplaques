require 'test_helper'

class AreasControllerTest < ActionController::TestCase
  
  context "when viewing the listing page for areas in a country" do
    setup do
      get(:index, {:country_id => countries(:gb).alpha2})
    end

    should respond_with :success
    should render_template :index

    should assign_to :country
    should assign_to :areas

  end  
  
  context "when getting the areas page for a non-existant country_id" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:index, {:country_id => "xx"})
      end
    end    
  end  
  
  context "when getting the page to add an area to a country" do
    
    context "when signed in as a user" do
    
      setup do
        sign_in users(:frankieroberto)
        get(:new, :country_id => countries(:gb).alpha2)                
      end
    
      should respond_with :success
      should render_template :new
      should assign_to :country
      should assign_to :area
    
    end
    
    context "when not signed in" do
    
      setup do
        get(:new, :country_id => countries(:gb).alpha2)                
      end
      
      should redirect_to("login page") {new_user_session_path}
    
    end
    
  end


  context "when getting an area page" do
    
    setup do
      area = areas(:london)
      get(:show, :id => area.slug, :country_id => area.country.alpha2)
    end
    
    should respond_with :success
    should render_template :show
    should assign_to :country
    should assign_to :area
    should assign_to :plaques
    should assign_to :zoom
    
  end
  
  context "when requesting a non-existant area page" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:show, {:id => "xxxxx", :country_id => countries(:gb).alpha2})
      end
    end    
    
  end

  context "when requesting an area page with a mismatched country_id" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:show, {:id => areas(:london).slug, :country_id => countries(:france).alpha2})
      end
    end    
    
  end


  context "when signed in as a user" do
    setup { sign_in users(:frankieroberto) }

    context "when submitting a valid new area" do
      setup do
        @country = countries(:gb)
        @area_slug = "new_area"        
        post :create, :country_id => @country.alpha2, :area => {:name => "test", :slug => @area_slug} 
      end
      
      should redirect_to("the page for the new area") { country_area_path(@country.alpha2, @area_slug) }
    end

    context "when submitting an invalid new area" do
      setup { post :create, :country_id => countries(:gb).alpha2 }
      
      should assign_to :area
      should render_template :new
    end
    
    
  end

  context "when submitting a new area" do
    
    setup do
      post(:create, {:country_id => countries(:gb).alpha2}, :area => {:name => "Test"})
    end
      
    should redirect_to("login page") {new_user_session_path}
  
  end

  context "when getting the edit area page" do
    
    context "when signed in" do
      
      setup do
        sign_in users(:frankieroberto)
        area = areas(:london)
        get(:edit, :id => area.slug, :country_id => area.country.alpha2)
      end
      
      should respond_with :success
      should assign_to :country
      should assign_to :countries
      should assign_to :area
      
    end
    
    context "when not signed in" do

      setup do
        area = areas(:london)
        get(:edit, :id => area.slug, :country_id => area.country.alpha2)
      end
      
      should redirect_to("login page") {new_user_session_path}
      
    end
    
  end

  context "when getting the page to add an area to an invalid country_id" do

    context "when signed in as a user" do

      setup do
        sign_in users(:frankieroberto)
      end

      should "raise a not-found error" do
        assert_raises(ActiveRecord::RecordNotFound) do      
          get(:new, :country_id => "xx")
        end
      end    

    end

  end
  
end
