class AddSlugToRoles < ActiveRecord::Migration
  def self.up
    add_column :roles, :slug, :string
    Role.find_each do |role|
      role.slug = role.name.downcase.gsub(" ", "_").gsub("'", "").gsub("-", "")
      role.save
    end

  end

  def self.down
    remove_column :roles, :slug
  end
end
