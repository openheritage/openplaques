class AddCountryIdToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :country_id, :integer
    
    locations = Location.find(:all)
    locations.each do |location|
      if location.area && location.area.country
        location.update_attributes(:country_id => location.area.country_id)
      end
    end
  end

  def self.down
    remove_column :locations, :country_id
  end
end
