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

  test "when requesting a non-existant page" do
    get(:show, {:area_id => "fictional_area", :country_id => "xx"})
    assert_response(404)
  end

  test "when getting a mis-matched area and country" do
    get(:show, {:area_id => areas(:london).slug, :country_id => countries(:france).alpha2})
    assert_response(404)
  end


end
