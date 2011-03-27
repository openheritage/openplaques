# This class represents a role ascribed to a person. These can be professions (eg 'doctor'), occupations ('artist'), or activities ('inventor').
#
# === Attributes
# * +name+ - The name of the role.
#
# === Associations
# * +people+ - The people who have been asctibed this role.
class Role < ActiveRecord::Base

  validates_presence_of :name, :slug
  validates_uniqueness_of :name, :slug
  validates_format_of :slug, :with => /^[a-z\_]+$/, :message => "can only contain lowercase letters and underscores"  

  has_many :personal_roles

  has_many :people, :through => :personal_roles, :order => :name

  before_save :update_index, :filter_name
  


  private
  
    def update_index
      self.index = self.name[0,1].downcase
    end
    
    def filter_name
      self.name = self.name.gsub(/\.?\??/, "").strip
    end

end
