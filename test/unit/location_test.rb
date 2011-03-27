require 'test_helper'

class LocationTest < ActiveSupport::TestCase

  should validate_presence_of :name

  should belong_to :area
  should belong_to :country


  should have_many :plaques
  should have_many :people
  should have_many :personal_connections
  should have_many :verbs
  


end
