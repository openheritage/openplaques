# This class represents 'countries', as defined by the ISO country codes specification.
# === Attributes
# * +name+ - the country's common name (not necessarily its official one).
# * +alpha2+ - 2-letter code as defined by the ISO standard. Used in URLs.
# * +dbpedia_uri+ - uri to link to DBPedia record
#
# === Associations
# * Areas - areas located in this country.
#
# === Indirect Associations
# * Plaques - plaques which are located in this country.
class Country < ActiveRecord::Base

  validates_presence_of :name, :alpha2
  validates_uniqueness_of :name, :alpha2
  validates_format_of :alpha2, :with => /^[a-z]{2}$/, :message => "must be a 2 letter code"

  has_many :areas
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

  def uri
    "http://openplaques.org" + Rails.application.routes.url_helpers.country_path(self, :format => :json)
  end

  def to_s
    name
  end

  def as_json(options={})
    super(options.merge(
      :only => [:name, :uri, :dbpedia_uri],
      :include => { :areas => {:only => [:name], :methods => :uri}},
      :methods => [:uri]
    ))
  end

end
