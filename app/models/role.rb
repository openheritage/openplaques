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


  def related_roles
    Role.find(:all, :conditions =>
      ['lower(name) != ? and (lower(name) LIKE ? or lower(name) LIKE ? or lower(name) LIKE ? )', name.downcase, 
    "#{name.downcase} %", "% #{name.downcase} %", "% #{name.downcase}"])
  end

  def person?
    return false if animal? or thing? or group? or place?
	return true
  end

  def animal?
    return true if "dog" == slug
    return true if "bulldog" == slug
	return false
  end

  def thing?
    return true if "battle" == slug
    return true if "bomb" == slug
    return false
  end

  def group?
    return true if "band" == slug
    return true if "battle" == slug
    return true if "bomb" == slug
    return true if "charity" == slug
    return true if "football_club" == slug
    return true if "society" == slug
    return true if "street" == slug
    return false
  end

  def place?
    #TODO add this as a settable attribute on role
    return true if "aerodrome" == slug
    return true if "almshouse" == slug
    return true if "asylum" == slug
    return true if "barracks" == slug
    return true if slug.start_with?("birthplace")
    return true if "brightons_smallest_pub" == slug
    return true if "cinema" == slug
    return true if "coffee_house" == slug
    return true if "fire_station" == slug
    return true if "football_ground" == slug
    return true if "grammar_school" == slug
    return true if "house" == slug
    return true if "mill" == slug
    return true if "pier" == slug
    return true if "public_house" == slug
    return true if "society" == slug
    return true if "street" == slug
    return true if "type_foundry" == slug
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

  private

    def update_index
      self.index = self.name[0,1].downcase
    end

    def filter_name
      self.name = self.name.gsub(/\.?\??/, "").strip
    end

end
