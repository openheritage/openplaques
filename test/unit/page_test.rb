require 'test_helper'

class PageTest < ActiveSupport::TestCase
  

  should validate_presence_of :name
  should validate_presence_of :slug
  should validate_presence_of :body
  
  should validate_uniqueness_of :slug

  should_not allow_value("About").for(:slug)
  should_not allow_value("Media Coverage").for(:slug)
  
  
end
