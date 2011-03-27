require 'test_helper'

class VerbsControllerTest < ActionController::TestCase

  context "when viewing the verbs index page" do
    setup { get :index }
      
    should respond_with :success
    should assign_to :verbs
    should render_template :index
  end

  context "when viewing a verb page" do
    setup { get :show, :id => verbs(:lived).name }

    should respond_with :success
    should assign_to :verb
    should render_template :show
  end
  
  context "when requesting a verb page with a verb name that doesn't exist" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) { get :show, :id => "xxxxx" }
    end    
    
  end  

  context "when requesting a verb page via its id" do
    setup { get :show, :id => verbs(:lived).id }
    
    should redirect_to("verb page") { verb_path(verbs(:lived).name) }
    
  end  
  
  context "when logged in as a user" do
    setup { sign_in users(:frankieroberto) }
    
    context "when viewing the new verb page" do
      setup { get :new }
      
      should respond_with :success
      should assign_to :verb
      should render_template :new
      
    end
    
    context "when submitting a valid new verb" do
      setup { post :create, :verb => {:name => "test"} }
      
      should redirect_to("the page for the new verb") { verb_path("test") }
    end

    context "when submitting an invalid new verb" do
      setup { post :create, :verb => {} }
      
      should assign_to :verb
      should render_template :new
    end

        
  end
  
  context "when not logged in as a user" do

    context "when viewing the new verb page" do
      setup { get :new }
      
      should redirect_to("login page") {new_user_session_path}
    end
    
    
  end
  
end
