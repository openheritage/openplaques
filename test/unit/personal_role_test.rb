require 'test_helper'

class PersonalRoleTest < ActiveSupport::TestCase

  should validate_presence_of :person_id
  should validate_presence_of :role_id

  should belong_to :person
  should belong_to :role
  should belong_to :related_person

end
