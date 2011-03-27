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

end
