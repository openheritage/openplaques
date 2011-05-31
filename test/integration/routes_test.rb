require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest
  fixtures :all

  should "route /about to the relevant page" do
    assert_routing '/about', { :controller => "pages", :action => "show", :id => "about" }
  end

  should "route /about/data to the relevant page" do
    assert_routing '/about/data', { :controller => "pages", :action => "show", :id => "data" }
  end

  should "route /contact to the relevant page" do
    assert_routing '/contact', { :controller => "pages", :action => "show", :id => "contact" }
  end

  
end
