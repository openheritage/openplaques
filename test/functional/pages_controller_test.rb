require 'test_helper'

class PagesControllerTest < ActionController::TestCase

  context "when viewing the About page" do
    setup do
      get(:show, {:id => "about"})
    end
    
    should respond_with :success
    should render_template :show
    should respond_with_content_type "text/html"
  end
  
  context "when not logged in" do
    
    
  end
  
  context "when logged in as an admin" do
    
    setup { sign_in users(:frankieroberto) }

      context "when viewing the edit page form" do
        
        setup { get :edit, :id => pages(:about_page).slug }
        
        should respond_with :success
        should assign_to :page
        
      end
  
  end
  


end
