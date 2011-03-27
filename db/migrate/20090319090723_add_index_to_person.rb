class AddIndexToPerson < ActiveRecord::Migration
  def self.up
    add_column :people, :index, :string
    
    Person.find(:all).each do |person|
      person.index = person.name[0,1].downcase
      person.save!
    end
  end

  def self.down
    remove_column :people, :index
  end
end
