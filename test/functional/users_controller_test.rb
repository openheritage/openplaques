require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context "when logged in as an admin" do

    setup { sign_in users(:frankieroberto) }

    context "when viewing a user page" do
      setup { get :show, :id => users(:frankieroberto).username }

      should respond_with :success
      should render_template :show
      should assign_to :user

    end
  
    context "when viewing a non-existant user's page" do

      should "raise a not-found error" do
        assert_raises(ActiveRecord::RecordNotFound) { get :show, :id => "xxxxx" }
      end    

    end  


    context "when viewing the page listing users" do

      setup { get :index }

      should respond_with :success
      should render_template :index
      should assign_to :users    
    
    end

    context "when viewing the page listing ALL users" do

      setup { get :index, :all => "yes" }

      should respond_with :success
      should render_template :index
      should assign_to :users    
    
    end

  end
  
end
