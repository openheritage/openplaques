require 'test_helper'

class LanguageTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_presence_of :alpha2

  should validate_uniqueness_of :name
  should validate_uniqueness_of :alpha2

  should_not allow_value("EN").for(:alpha2)
  should_not allow_value("eng").for(:alpha2)  
  should_not allow_value("en.").for(:alpha2)
  should_not allow_value("en-gb").for(:alpha2)  

  should have_many :plaques


end
