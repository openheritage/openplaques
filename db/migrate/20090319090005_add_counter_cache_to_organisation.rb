class AddCounterCacheToOrganisation < ActiveRecord::Migration
  def self.up
    add_column :organisations, :plaques_count, :integer
    
    Organisation.find(:all).each do |organisation|
      Organisation.update_counters(organisation.id, :plaques_count => Organisation.find(organisation.id).plaques.size)
    end
  end

  def self.down
    remove_column :organisations, :plaques_count
  end
end
