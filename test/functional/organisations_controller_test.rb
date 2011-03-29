require 'test_helper'

class OrganisationsControllerTest < ActionController::TestCase

  context "when vieiwng the organisations list page" do
    setup { get :index }
    
    should respond_with :success
    should assign_to :organisations
    should render_template :index
  end

  context "when requesting a non-existant organisation" do
    
    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:show, {:id => "fictiona_organisation"})
      end
    end  
  end
  
  context "when viewing an organisation page" do
    setup { get :show, :id => organisations(:english_heritage).slug }
  
    should respond_with :success
    should assign_to :organisation
    should render_template :show
  end
  
  
  context "when requesting an organisation page using its id" do

    setup do
      @organisation = organisations(:english_heritage)
      get(:show, {:id => @organisation.id})
    end

    should respond_with :moved_permanently
    should redirect_to("page using slug") {organisation_path(@organisation.slug)}

  end

  context "when signed in as a user" do
  
    setup { sign_in users(:frankieroberto) }
      
    context "when viewing the add organisation page" do
      
      setup { get :new }

      should respond_with :success
      should assign_to :organisation
      should render_template :new
      
    end
    
    context "when submitting a valid new organisation" do
      setup do
        @organisation_slug = "red_robin_society"
        post :create, :organisation => {:name => "Red Robin Society", :slug => @organisation_slug} 
      end
      
      should redirect_to("the page for the new organisation") { organisation_path(@organisation_slug) }
    end

    context "when submitting an invalid new organisation" do
      setup do
        post :create, :organisation => {} 
      end
      
      should assign_to :organisation
      should render_template :new
    end

    context "when viewing the edit organisation page" do
      
      setup { get :edit, :id => organisations(:english_heritage).slug }
      
      should respond_with :success
      should assign_to :organisation
      
    end
    
    context "when requesting the edit page for a non-existant organisation" do

      should "raise a not-found error" do
        assert_raises(ActiveRecord::RecordNotFound) do      
          get(:edit, {:id => "fictional_organisation"})
        end
      end  
    end
    
    context "when updating an organisation with valid new attributes" do
      
      setup do
        @organisation = organisations(:english_heritage)
        put :update, :id => @organisation.slug, :organisation => {:name => @organisation.name, :slug => @organisation.slug, :notes => "Test"}
      end
      
      should redirect_to("the page for the organisation") { organisation_path(@organisation.slug) }
      
    end

    context "when updating an organisation with invalid attributes" do
      
      setup do
        @organisation = organisations(:english_heritage)
        put :update, :id => @organisation.slug, :organisation => {:name => "", :slug => ""}
      end
      
      should render_template :edit
      should assign_to :organisation
      
    end

    context "when updating a non-existant organisation" do

      should "raise a not-found error" do
        assert_raises(ActiveRecord::RecordNotFound) do      
          put(:update, {:id => "fictional_organisation", :organisation => {}})
        end
      end  
    end


  end


  context "when not signed in" do
    
    context "when viewing the add organisation page" do      
      setup { get :new }      
      should redirect_to("login page") {new_user_session_path}      
    end
    
    
  end
  
end
