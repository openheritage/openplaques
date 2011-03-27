require 'test_helper'

class PersonalConnectionTest < ActiveSupport::TestCase

  should validate_presence_of :person_id
  should validate_presence_of :plaque_id
  should validate_presence_of :verb_id
  should validate_presence_of :location_id

  should belong_to :verb
  should belong_to :person
  should belong_to :plaque
  should belong_to :location  
  
end
