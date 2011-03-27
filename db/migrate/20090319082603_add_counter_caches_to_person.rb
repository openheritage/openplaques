class AddCounterCachesToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :personal_connections_count, :integer
    add_column :people, :personal_roles_count, :integer
    
    Person.find(:all).each do |person|
      Person.update_counters(person.id, :personal_connections_count => Person.find(person.id).personal_connections.size, :personal_roles_count => Person.find(person.id).personal_roles.size)
    end
  end

  def self.down
    remove_column :people, :personal_roles_count
    remove_column :people, :personal_connections_count
  end
end
