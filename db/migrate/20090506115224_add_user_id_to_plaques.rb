class AddUserIdToPlaques < ActiveRecord::Migration
  def self.up
    add_column :plaques, :user_id, :integer
    add_column :users, :plaques_count, :integer
    
    @plaques = Plaque.find(:all)
    @user = User.find(:first)
    @plaques.each do |plaque|
      plaque.user = @user
      plaque.save
    end
  end

  def self.down
    remove_column :users, :plaques_count    
    remove_column :plaques, :user_id
  end
end
