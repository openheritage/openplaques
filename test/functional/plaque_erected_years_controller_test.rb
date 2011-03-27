require 'test_helper'

class PlaqueErectedYearsControllerTest < ActionController::TestCase

  context "when viewing the page for plaques erected in a particular year" do
    setup { get :show, :id => plaque_erected_years(:y2k).name }
    
    should respond_with :success
    should render_template :show
    should assign_to :plaque_erected_year
    
  end

  context "when requesting a non-existant year" do
    
    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:show, {:id => "XXXXX"})
      end
    end  
  end


  context "when viewing the page listing years plaques were erected in" do
    setup { get :index }
    
    should respond_with :success
    should render_template :index
    should assign_to :plaque_erected_years
    
  end



end
