require 'test_helper'

class OrganisationTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_presence_of :slug

  should validate_uniqueness_of :slug
  
  should have_many :plaques

end
