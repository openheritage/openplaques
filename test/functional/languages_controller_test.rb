require 'test_helper'

class LanguagesControllerTest < ActionController::TestCase

  context "when requesting a non-existant language" do

    should "raise a not-found error" do
      assert_raises(ActiveRecord::RecordNotFound) do
        get(:show, {:id => "zz"})
      end
    end
  end

  context "when viewing languages index page" do
    setup { get :index }

    should respond_with :success
    should render_template :index

    should "have a meaningful page title" do
      assert_select 'h1', 'Plaques - by language'
    end

  end

  context "when vieiwng a language page" do
    setup do
      get(:show, {:id => languages(:english).alpha2})
    end

    should respond_with :success
    should assign_to :language
    should render_template :show
  end


  context "when vieiwng a language page using its legacy id-based URL" do
    setup do
      @language = languages(:english)
      get :show, {:id => @language.id}
    end

    should respond_with :moved_permanently
    should redirect_to("language page") {language_path(@language.alpha2)}

  end

end
