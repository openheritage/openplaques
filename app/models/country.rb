# This class represents 'countries', as defined by the ISO country codes specification.
# === Attributes
# * +name+ - the country's common name (not necessarily its official one).
# * +alpha2+ - 2-letter code as defined by the ISO standard. Used in URLs.
#
# === Associations
# * Plaques - plaques which are located in this country.
# * Areas - areas located in this country.
# * Locations - locations within this country.
class Country < ActiveRecord::Base

  validates_presence_of :name, :alpha2
  validates_uniqueness_of :name   # Unlikely that we'll get two countries with the same name...
  validates_uniqueness_of :alpha2
  validates_format_of :alpha2, :with => /^[a-z]{2}$/, :message => "must be a 2 letter code"

  has_many :areas
  has_many :locations, :through => :areas
  has_many :plaques, :through => :locations
  
  def latitude
    52
  end
  
  def longitude
    0
  end
  
  def zoom
    6
  end

  # Construct paths using the alpha2 code
  def to_param
    alpha2
  end
  
  def to_s
    name
  end

end
