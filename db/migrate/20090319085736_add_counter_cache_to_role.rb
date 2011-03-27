class AddCounterCacheToRole < ActiveRecord::Migration
  def self.up
    add_column :roles, :personal_roles_count, :integer

    Role.find(:all).each do |role|
      Role.update_counters(role.id, :personal_roles_count => Role.find(role.id).personal_roles.size)
    end

  end

  def self.down
    remove_column :roles, :personal_roles_count
  end
end
