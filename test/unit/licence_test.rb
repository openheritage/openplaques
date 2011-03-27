require 'test_helper'

class LicenceTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_presence_of :url

  should validate_uniqueness_of :url

  should have_many :photos


end
