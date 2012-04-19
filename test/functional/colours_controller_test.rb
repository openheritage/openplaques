require 'test_helper'

class ColoursControllerTest < ActionController::TestCase

  context "when viewing the index page" do

    setup do
      get :index
    end

    should respond_with :success
    should assign_to :colours
  end


  context "when viewing a colour page" do
    setup do
      get :show, {:id => colours(:blue).slug}
    end

    should respond_with :success
    should assign_to :colour

  end

  context "when viewing a legacy colour URL identified by an id" do

    setup do
      @colour = colours(:blue)
      get(:show, {:id => @colour.id})
    end

    should respond_with :moved_permanently
    should redirect_to("color page") {colour_path(@colour.name)}
  end

  test "requesting a non-existant colour" do
    get(:show, {:id => "blueygreenorange"})
    assert_response(404)
  end

  context "when signed in" do

    setup do
      sign_in users(:frankieroberto)
    end

    context "when viewing the new colour page" do
      setup { get :new }

      should respond_with :success
      should assign_to :colour
    end

    context "when viewing the edit colour page" do
      setup { get :edit, :id => colours(:blue).name }

      should respond_with :success
      should assign_to :colour
    end

    context "when submitting a valid new colour" do

      setup do
        @slug = "purple"
        post :create, :colour => {:slug => @slug, :name => "purple"}
      end

      should redirect_to("the page for the new colour") { colour_path(@slug) }

    end

    context "when submitting an invalid new colour" do

      setup do
        post :create, :colour => {}
      end

      should assign_to :colour
      should render_template :new

    end

    context "when updating a colour with valid new attributes" do

      setup do
        @slug = "blue_new"
        put :update, :id => colours(:blue).slug, :colour => {:slug => @slug, :name => "new blue"}
      end

      should redirect_to("the page for the new colour") { colour_path(@slug) }

    end

    context "when updating a colour with invalid new attributes" do

      setup do
        put :update, :id => colours(:blue).slug, :colour => {:slug => ""}
      end

      should assign_to :colour
      should render_template :edit

    end

  end


end
