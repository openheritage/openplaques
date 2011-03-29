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


  end


  context "when not signed in" do
    
    context "when viewing the add organisation page" do      
      setup { get :new }      
      should redirect_to("login page") {new_user_session_path}      
    end
    
    
  end
  
end
