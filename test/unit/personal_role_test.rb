require 'test_helper'

class PersonalRoleTest < ActiveSupport::TestCase

  should validate_presence_of :person_id
  should validate_presence_of :role_id
  
  should validate_uniqueness_of(:person_id).scoped_to(:role_id)
  
  should belong_to :person
  should belong_to :role

end
