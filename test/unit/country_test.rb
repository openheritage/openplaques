require 'test_helper'

class CountryTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_presence_of :alpha2

  should validate_uniqueness_of :name
  should validate_uniqueness_of :alpha2

  should_not allow_value("GB").for(:alpha2)
  should_not allow_value("fra").for(:alpha2)
  should_not allow_value("gb.").for(:alpha2)
  should_not allow_value("u-s-a").for(:alpha2)

  should have_many :areas
  should have_many :locations
  should have_many :plaques


end
