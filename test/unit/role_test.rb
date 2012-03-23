require 'test_helper'

class RoleTest < ActiveSupport::TestCase

  should validate_presence_of :name
  should validate_presence_of :slug

  should validate_uniqueness_of :name
  should validate_uniqueness_of :slug

  should allow_value("illustrator").for(:slug)
  should allow_value("inventor_of_the_penny_farthing").for(:slug)

  should_not allow_value("Illustrator").for(:slug)
  should_not allow_value("inventor of the penny farthing").for(:slug)


  should have_many :people
  should have_many :personal_roles


  context "when creating a role" do

    setup { @role = Role.create(:name => "test", :slug => "test")}

    should "set the index letter of a role" do
      assert_equal "t", @role.index
    end

    teardown { @role.destroy }

  end

  context "when updating a role" do

    setup do
      @role = Role.create(:name => "test", :slug => "test")
      @role.update_attributes(:name => "changed", :slug => "changed")
    end

    should "update the index letter of a role" do
      assert_equal "c", @role.index
    end

    teardown { @role.destroy }

  end


end
