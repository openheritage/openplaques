class AddPlaqueConnectionsCountToPlaque < ActiveRecord::Migration
  def self.up
    add_column :plaques, :plaque_connections_count, :integer

    Plaque.find(:all).each do |plaque|
      Plaque.update_counters(plaque.id, :plaque_connections_count => Plaque.find(plaque.id).plaque_connections.size)
    end


  end

  def self.down
    remove_column :plaques, :plaque_connections_count
  end
end
