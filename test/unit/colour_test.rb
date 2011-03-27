require 'test_helper'

class ColourTest < ActiveSupport::TestCase

  should validate_presence_of :name

  should validate_uniqueness_of :name

  should have_many :plaques

end
