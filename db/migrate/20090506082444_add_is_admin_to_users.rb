class AddIsAdminToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_admin, :boolean
    @users = User.find(:all)
    @users.each do |user|
      user.make_admin
    end
  end

  def self.down
    remove_column :users, :is_admin
  end
end
