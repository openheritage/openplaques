# This class represents a role ascribed to a person. These can be professions (eg 'doctor'), occupations ('artist'), or activities ('inventor').
#
# === Attributes
# * +name+ - The name of the role.
# * +role_type+ - The classification of the role (see self.types for choice)
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


  def related_roles
    Role.find(:all, :conditions =>
      ['lower(name) != ? and (lower(name) LIKE ? or lower(name) LIKE ? or lower(name) LIKE ? )', name.downcase, 
    "#{name.downcase} %", "% #{name.downcase} %", "% #{name.downcase}"])
  end
  
  def self.types
    ["person", "animal", "thing", "group", "place", "relationship"]
  end

  def person?
    return false if animal? or thing? or group? or place?
	  return true
  end

  def animal?
    return true if "animal" == role_type
	  return false
  end

  def thing?
    return true if "thing" == role_type
    return false
  end

  def group?
    return true if "group" == role_type
    return false
  end

  def place?
    return true if "place" == role_type
#    return true if slug.start_with?("birthplace")
#    return true if slug.start_with?("where_")
    return false
  end
  
  def type
	  return "person" if person?
	  return "animal" if animal?
	  return "thing" if thing?
	  return "group" if group?
	  return "place" if place?
	  return "?"
  end
  
  # work it out from the name unless override value stored in the db
  def wikipedia_stub
    self[:wikipedia_stub] ? self[:wikipedia_stub] : self.name.capitalize.strip.gsub(/ /,"_")
  end
  
  def dbpedia_url
    "http://dbpedia.org/resource/" + wikipedia_stub
  end
  
  def wikipedia_url
    "http://en.wikipedia.org/wiki/" + wikipedia_stub
  end
  
  def relationship?
    return true if "relationship" == role_type
#    return true if slug.include?("kings_")
    return false
  end

  private

    def update_index
      self.index = self.name[0,1].downcase
    end

    def filter_name
      self.name = self.name.gsub(/\.?\??/, "").strip
    end

end
