class AddCounterCacheToVerb < ActiveRecord::Migration
  def self.up
    add_column :verbs, :personal_connections_count, :integer
    
    Verb.find(:all).each do |verb|
      Verb.update_counters(verb.id, :personal_connections_count => Verb.find(verb.id).personal_connections.size)
    end    
  end

  def self.down
    remove_column :verbs, :personal_connections_count
  end
end
