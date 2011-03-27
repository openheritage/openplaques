class AddSlugToCountries < ActiveRecord::Migration
  def self.up
    add_column :areas, :slug, :string
    areas = Area.all
    areas.each do |area|
      area.slug = area.name.downcase.gsub!(" ", "_")
      area.save
    end
  end

  def self.down
    remove_column :areas, :slug
  end
end
