# This class represents 'areas', which are the largest commonly identified region of
# residence  below a country level. By this, we mean the place that people would normally
# name in answer to the question of 'where do you live?' In most cases, this will be either
# a city (eg 'London'), town (eg 'Margate'), or village. It should not normally be either a
# state, county, district or other administrative region.
#
# === Attributes
# * +name+ - the area's common name (not neccessarily 'official')
# * +slug+ - an identifier used in URLs. Normally a lower-cased version of name, with spaces replaced by underscores
#
# === Associations
# * Country - country in which the area falls geographically or administratively.
# * Plaques - plaques located in this area.
class Area < ActiveRecord::Base

  before_validation :make_slug_not_war
  validates_presence_of :name, :slug, :country_id
  validates_uniqueness_of :slug, :scope => :country_id
  validates_format_of :slug, :with => /^[a-z\_]+$/, :message => "can only contain lowercase letters and underscores"

  belongs_to :country, :counter_cache => true
  delegate :alpha2, :to => :country, :prefix => true

  has_many :locations
  has_many :plaques, :through => :locations

  def as_json(options={})
    {:label => name, :value => name, :id => id, :country_id => country.id, :country_name => country.name}
  end

  def to_param
    slug
  end
  
  private
    def make_slug_not_war
      self.slug = (self.slug.blank? ? self.name : self.slug).rstrip.lstrip.downcase.gsub(" ", "_").gsub("-", "_").gsub(",", "_")
    end

end
