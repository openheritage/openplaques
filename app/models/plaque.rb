# -*- encoding : utf-8 -*-
# This class represents a physical commemorative plaque, which is either currently installed, or
# was once installed on a building, site or monument. Our definition of plaques is quite wide,
# encompassing 'traditional' blue plaques that commemorate a historic person's connection to a
# place, as well as plaques that commemorate buildings, events, and so on.
#
# === Attributes
# * +inscription+ - The text inscription on the plaque.
# * +inscription_is_stub+ - The inscription is incomplete and needs entering.
# * +erected_at+ - The date on which the plaque was erected. Optional.
# * +reference+ - An official reference number or identifier for the plaque. Sometimes marked on the actual plaque itself, sometimes only in promotional material. Optional.
# * +latitude+ - The latitude of the plaque's location (as a decimal in WSG-84 projection). Optional.
# * +longitude+ - The longitude of the plaque's location (as a decimal in WSG-84 projection). Optional.
# * +notes+ - A general purpose notes field for internal admin and data-collection purposes.
#
# === Associations
# * Location - The location where the plaque is (or was) installed. Optional.
# * Area - The area in which the plaque is (or was) installed. Optional.
# * Colour - The colour of the plaque. Optional.
# * Organisation - The organisation responsible for the plaque. Optional.
# * User - The user who first added the plaque to the website.
# * Language - The primary language of the inscripton on the plaque. Optional.
# * Photos - Photos of the plaque.
# * Verbs - The verbs used on the plaque's inscription.
# * Series - A series that this plaque is part of. Optional.
class Plaque < ActiveRecord::Base

  validates_presence_of :user

  belongs_to :location, :counter_cache => true
  belongs_to :colour, :counter_cache => true
#  belongs_to :organisation, :counter_cache => true
  belongs_to :plaque_erected_year, :counter_cache => true
  belongs_to :user, :counter_cache => true
  belongs_to :language, :counter_cache => true
  belongs_to :series, :counter_cache => true

  has_one :area, :through => :location
  has_one :pick

  has_many :personal_connections
#  has_many :verbs, :through => :personal_connections
  has_many :photos, :inverse_of => :plaque
  has_many :sponsorships
  has_many :organisations, :through => :sponsorships

  before_save :set_erected_year, :use_other_colour_id

  scope :geolocated, :conditions => ["latitude IS NOT NULL"]
  scope :ungeolocated, :conditions => {:latitude => nil} , :order => "id DESC"
  scope :photographed, :conditions => ["photos_count > 0"]
  scope :unphotographed, :conditions => {:photos_count => 0} , :order => "id DESC"
  scope :coloured, :conditions => ["colour_id IS NOT NULL"]
  scope :photographed_not_coloured, :conditions => ["photos_count > 0 AND colour_id IS NULL"]
  scope :geo_no_location, :conditions => ["latitude IS NOT NULL AND location_id IS NULL"]
  scope :detailed_address_no_geo, :conditions => ["latitude IS NULL AND 1 = ((SELECT name FROM locations WHERE locations.id = location_id) REGEXP '.*[0-9].*')"]
  scope :no_connection, :conditions => {:personal_connections_count => 0} , :order => "id DESC"
  scope :no_description, where("description = '' OR description IS NULL")
  scope :partial_inscription, :conditions => {:inscription_is_stub => true } , :order => "id DESC"
  scope :partial_inscription_photo, :conditions => {:photos_count => 1..99999, :inscription_is_stub => true} , :order => "id DESC"

  attr_accessor :country, :other_colour_id

  delegate :name, :to => :colour, :prefix => true, :allow_nil => true
  delegate :name, :alpha2, :to => :language, :prefix => true, :allow_nil => true

  accepts_nested_attributes_for :photos, :reject_if => proc { |attributes| attributes['photo_url'].blank? }
  accepts_nested_attributes_for :user, :reject_if => :all_blank

  include ApplicationHelper, ActionView::Helpers::TextHelper

  def user_attributes=(user_attributes)

    if user_attributes.has_key?("email")
      user = User.find_by_email(user_attributes["email"])
      if user
        raise "Attempting To Post Plaque As Existing Verified User" and return if user.is_verified?
        self.user = user
      end
    end

    if !self.user
      self.build_user(user_attributes)
    end

  end

  def to_csv
   [self.id, self.inscription_csv, self.organisation_name, self.erected_at_string, self.language_name, self.colour_name.to_s, self.location_name, self.area_name, self.country_name, "\"" + self.coordinates + "\""].join(",")
  end

  def inscription_csv
    if self.inscription
      '"' + self.inscription.gsub('"', '""') + '"'
    else
      ""
    end
  end

  def coordinates
    if self.geolocated?
      self.latitude.to_s + "," + self.longitude.to_s
    else
      ""
    end
  end

  def location_name
    if self.location && self.location.name
      '"' + self.location.name.gsub('"', '""') + '"'
    else
      ""
    end
  end

  def area_name
    if self.location && self.location.area
      self.location.area.name
    else
      ""
    end
  end

  def country_name
    if self.location && self.location.area && self.location.area.country
      self.location.area.country.name
    else
      ""
    end
  end
  def organisation_name
    if self.organisation
      self.organisation.name
    else
      ""
    end
  end

  def location_string
    if self.location
      self.location.name
    else
      nil
    end
  end

  def erected_at_string
    if self.erected_at?
      if self.erected_at.month == 1 && self.erected_at.day == 1
        self.erected_at.year.to_s
      else
        self.erected_at.to_s
      end
    else
      nil
    end
  end

  def erected_at_string=(date)
    if date.length == 4
      self.erected_at = Date.parse(date + "-01-01")
    else
      self.erected_at = date
    end
  end

  def parse_inscription
    inscription = self.inscription
    if inscription

      inscription_regex = /\A(.+?),?\s(([a-z]+ed|was born|grew up|taught|wrote\s\'[a-zA-Zü\s]+\')(\sand\s(([a-z]+ed)|was born|grew up|taught|wrote\s\'[a-zA-Zü\s]+\'))?)\s(at\s)?(.+?)(\.?)\Z/

      if inscription =~ inscription_regex

        subject = inscription[inscription_regex, 1]
        predicates = inscription[inscription_regex, 2]
        object = inscription[inscription_regex, 8]

        subjects = []

        subjects_regex =
            %r{
                (
                  (
                    \'?[A-Z][a-züA-Z]+\'?|    # First name
                    ([A-Z]\.)+         # or initial
                  )
                  (
                  \s
                  (
                    [A-Z][a-züA-Z]+|                # additional name
                    de\s[A-Z][a-zA-Zü]+|                         # or de
                    [A-Z]\.)|(                     # or initial  - eg F.
                    \,\sEarl\sof[A-Z][a-z]+|
                    \salias\s\'[A-Za-z]+\'|   # alias
                    \s\'[A-Z][a-z]+\'|
                    \sof\s[A-Z][a-z]+|
                    \s\([A-Z][A-Za-zü\s]+\)
                  ))+
                )
                (\s\(c?[\d]{4}-c?[\d]{4}\))?  # Dates - eg {1934-2004}
                (
                  \,?\s     # optional comma, followed by a space
                  [a-zA-Z\s\,\d\-\'\&]+   # roles
                )?
              }x


        subject.gsub(subjects_regex) do |s|
          subjects << s
        end



        subjects.each do |subject|

          person = Person.find_or_create_by_name_and_dates_and_roles(subject)

          predicates.split(" and ").each do |predicate|
            verb = Verb.find_or_create_by_name(predicate)

            if object =~ /here(\s(in\s)?\d{4}-\d{4})?\.?/
              if self.location
                location = self.location
                if object =~ /here\s(in\s)?\d{4}-\d{4}?\.?/
  #                started_at = Date.today
  #                ended_at = Date.today
                  started_at = DateTime.parse(object[/here\s(in\s)?(\d{4})-\d{4}\.?/, 2] + "-01-01")
                  ended_at = DateTime.parse(object[/here\s(in\s)?\d{4}-(\d{4})\.?/, 2] + "-01-01")
                  personal_connection = PersonalConnection.new(:person => person, :verb => verb, :location => location, :started_at => started_at, :ended_at => ended_at, :plaque => self)
                else
                  personal_connection = PersonalConnection.new(:person => person, :verb => verb, :location => location,:plaque => self)
                end
              else
                # Can't create connection as 'here' refers to
                # an unspecified location.
                break
              end
            else
              location = Location.find_or_create_by_name(object)
              personal_connection = PersonalConnection.new(:person => person, :verb => verb, :location => location, :plaque => self)
            end

            personal_connection.save!

          end
        end
      end

      return self.personal_connections

    end

  end

  def geolocated?
    !(self.latitude.nil?)
  end

  def photographed?
    self.photos_count > 0
  end

  def unparse_inscription
    if self.personal_connections.size > 0
      self.personal_connections.each do |personal_connection|
        personal_connection.destroy
      end
    end
  end

  def first_person
    if personal_connections.size > 0
      personal_connections[0].person.name
    else
      return nil
    end
  end

  def people
    people = Array.new
    self.personal_connections.each do |personal_connection|
      if personal_connection.person != nil && personal_connection.person.name != ""
        people << personal_connection.person
      end
    end
    return people.uniq
  end

  def as_json(options={})
    # this example ignores the user's options

    default_options = {:only => [:id, :inscription, :latitude, :longitude, :erected_at, :updated_at],
    :include => {
      :photos => {:only => [:id,:thumbnail_url]},
      :organisations => {:only => [:name, :id]},
      :colour => {:only => :name},
      :language => {:only => [:name, :alpha2]},
      :location => {:only => :name,
        :include => {
          :area => {:only => :name, :include => {:country => {:only => [:name, :alpha2]}}}
        }
      }
    },
    :methods => [:title, :colour_name, :machine_tag, :geolocated?, :photographed?, :url, :photo_url, :thumbnail_url, :shot_name]
    }

    if options.size > 0
      super(default_options.merge(options))
    else
      super(default_options)
    end
  end

  def machine_tag
    "openplaques:id=" + id.to_s
  end

  def title
    if people.size > 4
      first_4_people = []
      people.first(4).each do |person|
        first_4_people << person[:name]
      end
      first_4_people << pluralize(people.size - 4, "other")
      first_4_people.to_sentence
    elsif people.size > 0
      people.collect(&:name).to_sentence + " " + (colour_name || 'unknown') + " plaque"
    else
      colour_name.capitalize + " plaque № #{id}"
    end << (area_name != "" ? " in " : "") + area_name
  end

  def main_photo
    if !self.photos.empty?
      return photos.detail_order.first
    end
  end
  def main_photo_reverse
    if !self.photos.empty?
      return photos.reverse_detail_order.first
    end
  end

  def thumbnail_url
    if main_photo == nil
      return nil
    end
    main_photo.thumbnail_url != "" ? main_photo.thumbnail_url : main_photo.file_url
  end

  def foreign?
    begin
      self.language.alpha2 != "en"
    rescue
      false
    end
  end

  # so that old code still works
  def organisation
    self.organisations[0]
  end

  # so that old code still works
  def organisation=(organisation)
    if organisation
      sponsorship = self.sponsorships.new
      sponsorship.organisation = organisation
    end
  end

  def to_s
    self.title
  end

  private

    def use_other_colour_id
      if !self.colour && self.other_colour_id
        self.colour_id = self.other_colour_id
      end
    end

    def set_erected_year
      if self.erected_at?
        plaque_erected_year = PlaqueErectedYear.find_or_create_by_name(self.erected_at.year.to_s)
        self.plaque_erected_year = plaque_erected_year
      end
    end
end
