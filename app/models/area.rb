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
require 'curb'

class Area < ActiveRecord::Base

  before_validation :make_slug_not_war
  validates_presence_of :name, :slug, :country_id
  validates_uniqueness_of :slug, :scope => :country_id
  validates_format_of :slug, :with => /^[a-z\_]+$/, :message => "can only contain lowercase letters and underscores"

  belongs_to :country, :counter_cache => true
  delegate :alpha2, :to => :country, :prefix => true

  has_many :locations
  has_many :plaques, :through => :locations

  include ApplicationHelper

  def as_json(options={})
    {:label => name, :value => name, :id => id, :country_id => country.id, :country_name => country.name}
  end

  def latitude_or_default
    if !latitude.blank?
      latitude
    elsif plaques.geolocated.first
      plaques.geolocated.first.latitude
    else
      nil
    end
  end

  def longitude_or_default
    if !longitude.blank?
      longitude
    elsif plaques.geolocated.first
      plaques.geolocated.first.longitude
    else
      nil
    end
  end

  def self.find_or_create_by_woeid(woeid)
    url = "http://where.yahooapis.com/geocode?flags=J&woeid=" + woeid
    begin
      ch = Curl::Easy.perform(url) do |curl| 
        curl.headers["User-Agent"] = "openplaques"
        curl.verbose = true
      end
      parsed_json = JSON.parse(ch.body_str)
      parsed_json['ResultSet']['Results'].each do |result|
        city = result['city']
        if (result['countrycode']=='US' || result['countrycode']=='CA')
          city += ", "+ result['statecode']
        end
        country = Country.find_by_name(result['country'])
        a = Area.find_or_create_by_name_and_country_id(city, country.id)
        if (!a.latitude)
          a.latitude = result['latitude']
          a.longitude = result['longitude']
          a.save
        end
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
