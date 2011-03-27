require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase

  should validate_presence_of :username
  should validate_presence_of :email
  should validate_uniqueness_of :username
  should validate_uniqueness_of :email
    
  should have_many :plaques

end
