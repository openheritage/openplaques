class AddSlugToColours < ActiveRecord::Migration
  class Colour < ActiveRecord::Base 
  end
  def self.up
    add_column :colours, :slug, :string
    add_index :colours, :slug
    
    Colour.find_each do |colour|      
      slug = colour.name.downcase.gsub(" ", "_").gsub(/[\,\.]/, "")
      colour.update_attribute(:slug, slug)
    end
    
    
  end

  def self.down
    remove_index :colours, :slug
    remove_column :colours, :slug
  end
end