require 'test_helper'

class PlaqueErectedYearTest < ActiveSupport::TestCase
  
  should validate_presence_of :name
  
  should validate_uniqueness_of :name
  
  should have_many :plaques

end
