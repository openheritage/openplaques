require 'test_helper'

class PhotoTest < ActiveSupport::TestCase

  should validate_presence_of(:plaque_id)
  should validate_presence_of(:file_url)
  should validate_presence_of(:url)
  should validate_presence_of(:licence_id)

  should belong_to :plaque
  should belong_to :licence

end
