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
  
  
  should "be redirected" do
    get(:show, {:id => organisations(:english_heritage).id})
    assert_response(301)
    assert_redirected_to({:id => organisations(:english_heritage).slug})      
  end

end
