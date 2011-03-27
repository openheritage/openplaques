require 'test_helper'

class VerbTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_uniqueness_of :name
  
  should have_many :personal_connections
  should have_many :plaques
  should have_many :people
  should have_many :locations
    
end
