class AddIndexToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :index, :string

    Role.find(:all).each do |role|
      role.index = role.name[0,1].downcase
      role.save!
    end


  end

  def self.down
    remove_column :roles, :index
  end
end
