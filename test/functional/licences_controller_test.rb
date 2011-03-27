require 'test_helper'

class LicencesControllerTest < ActionController::TestCase

  context "when viewing the licence index page" do
    setup  { get :index }
      
    should respond_with :success
    should assign_to :licences
    should render_template :index
  end

  context "when viewing a licence page" do
    setup { get :show, :id => licences(:ccby).id }

    should respond_with :success
    should assign_to :licence
    should render_template :show
  end

end
