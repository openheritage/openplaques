require 'test_helper'

class RolesControllerTest < ActionController::TestCase

  context "when not signed in" do
    
    context "when viewing the index page" do
      setup { get :index }
      
      should redirect_to("roles by index page") { roles_by_index_path }
    end

    context "when viewing a role page" do
      setup { get :show, :id => roles(:prime_minister).slug }
      
      should respond_with :success
      should assign_to :role
      should render_template :show
    end

    context "when requesting the new role page" do
      setup { get :new }
    
      should redirect_to("login page") { new_user_session_path }
    end

    context "when requesting the edit role page" do
      setup { get :edit, :id => roles(:prime_minister).slug }
    
      should redirect_to("login page") { new_user_session_path }
    end
    
    
  end
  
  context "when signed in as a user" do
    
    setup { sign_in users(:frankieroberto) }
    
    context "when viewing the new role page" do
      setup { get :new }
      
      should respond_with :success
      should assign_to :role
      should render_template :new
      
    end

    context "when viewing the edit role page" do
      setup { get :edit, :id => roles(:prime_minister).slug }
      
      should respond_with :success
      should assign_to :role
      should render_template :edit
      
    end
    
    
  end


end
