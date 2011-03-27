class AddPhotosCountToLicense < ActiveRecord::Migration
  def self.up
    add_column :licenses, :photos_count, :integer
  end

  def self.down
    remove_column :licenses, :photos_count
  end
end
