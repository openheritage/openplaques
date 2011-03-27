require 'test_helper'

class AreaUngeolocatedPlaquesControllerTest < ActionController::TestCase

  context "when getting a page for ungeolocated plaques in an area" do
    setup do
      area = areas(:london)
      get(:show, {:area_id => area.slug, :country_id => area.country.alpha2})
    end

    should respond_with :success
    should render_template :show

    should assign_to :area
    should assign_to :country
    should assign_to :plaques

  end

  context "when requesting a non-existant page" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:show, {:area_id => "fictional_area", :country_id => "xx"})
      end
    end    
  end

  context "when getting a mis-matched area and country" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do      
        get(:show, {:area_id => areas(:london).slug, :country_id => countries(:france).alpha2})
      end
    end    
  end
  

end
