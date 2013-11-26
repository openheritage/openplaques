# This class represents 'areas', which are the largest commonly identified region of
# residence  below a country level. By this, we mean the place that people would normally
# name in answer to the question of 'where do you live?' In most cases, this will be either
# a city (eg 'London'), town (eg 'Margate'), or village. It should not normally be either a
# state, county, district or other administrative region.
#
# === Attributes
# * +name+ - the area's common name (not neccessarily 'official')
# * +slug+ - an identifier used in URLs. Normally a lower-cased version of name, with spaces replaced by underscores
# * +latitude+ - Mean location of plaques
# * +longitude+ - Mean location of plaques
#
# === Associations
# * Country - country in which the area falls geographically or administratively.
# * Locations - places that are in this are
# * Plaques - plaques located in this area (via locations).
require 'curb'

class Area < ActiveRecord::Base

  before_validation :make_slug_not_war, :find_centre
  validates_presence_of :name, :slug, :country_id
  validates_uniqueness_of :slug, :scope => :country_id
  validates_format_of :slug, :with => /^[a-z\_]+$/, :message => "can only contain lowercase letters and underscores"

  belongs_to :country, :counter_cache => true
  delegate :alpha2, :to => :country, :prefix => true

  has_many :locations
  has_many :plaques, :through => :locations

  include ApplicationHelper
  include PlaquesHelper
  
  def as_json(options={})
    {:label => name, :value => name, :id => id, :country_id => country.id, :country_name => country.name}
  end

  def find_centre
    if (self.latitude == nil && self.longitude == nil || self.latitude == 51.475 && self.longitude == 0)
      @mean = find_mean(self.plaques.geolocated)
      self.latitude = @mean.latitude
      self.longitude = @mean.longitude
    end
  end
  
  def self.find_or_create_by_woeid(woeid)
    url = "http://where.yahooapis.com/geocode?flags=J&woeid=" + woeid
    begin
      ch = Curl::Easy.perform(url) do |curl| 
        curl.headers["User-Agent"] = "openplaques"
        curl.verbose = true
      end
      puts ch.body_str
      
      json = JSON.parse(ch.body_str)
      json['ResultSet']['Results'].each do |result|
        city = result['city']
        if (result['countrycode']=='US' || result['countrycode']=='CA')
          city += ", "+ result['statecode']
        end
        country = Country.find_by_name(result['country'])
        a = Area.find_or_create_by_name_and_country_id(city, country.id)
        puts "area name is " + a.name
        if (!a.latitude)
          a.latitude = result['latitude']
          a.longitude = result['longitude']
          a.save
        end
        return a
      end
    rescue
    end
  end

  def to_param
    slug
  end
  
  def to_s
    name
  end

end
