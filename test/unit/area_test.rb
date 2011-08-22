require 'test_helper'

class AreaTest < ActiveSupport::TestCase
  # Replace this with your real tests.

  should validate_presence_of :name
  should validate_presence_of :slug
  should validate_presence_of :country_id

  should_not allow_value("London").for(:slug)
  should_not allow_value("Kingston Upon Hull").for(:slug)

  should belong_to :country

  should have_many :locations
  should have_many :plaques

  should "validate uniqueness of slug" do
    area = Area.new(:name => "Second London", :slug => :london)
    assert !area.save
  end

end
