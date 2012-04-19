require 'test_helper'

class CountriesControllerTest < ActionController::TestCase

  context "when viewing the countries page" do
    setup do
      get :index
    end

    should respond_with :success
    should assign_to :countries
  end

  context "when viewing a country page" do
    setup do
      get(:show, {:id => countries(:gb).alpha2})
    end

    should respond_with :success
    should assign_to :country

  end

  context "when requesting a country page using its legacy URL with an id" do
    setup do
      @country = countries(:gb)
      get(:show, {:id => @country.id})
    end

    should respond_with :moved_permanently
    should redirect_to("country page") {country_path(@country.alpha2)}

  end

  test "requesting non-existant country" do
    get :show, {:id => "zz"}
    assert_response(404)
  end


end
