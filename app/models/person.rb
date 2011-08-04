require 'rubygems'
require 'open-uri'

# This class represents a human who has been commemorated on a plaque.
# === Attributes
# * +name+ - The common full name of the person.
# * +wikipedia_url+ - An override link to the person's Wikipedia page (if they have one and it isn't linked to via their name).
# * +dbpedia_uri+ - A link to the DBpedia resource representing the person (if one exists).
# * +born_on+ - The date on which the person was born. Optional.
# * +died_on+ - The date on which the person died. Optional.
# * +born_on_is_circa+ - True or False. Whether the +born_on+ date is 'circa' or not. Optional.
# * +died_on_is_circa+ - True or False. Whether the +died_on+ date is 'circa' or not. Optional.

# === Associations
# * Plaques - plaques on which this person is commemorated.
# * Roles - roles associated with this person (eg 'carpenter').
# * Locations - locations associated with this person (via plaques).
# * Verbs - verbs associated with this person (via plaques).

class Person < ActiveRecord::Base

  validates_presence_of :name

  validates_uniqueness_of :wikipedia_url, :allow_nil => true, :allow_blank => true
  validates_uniqueness_of :dbpedia_uri, :allow_nil => true, :allow_blank => true

  has_many :roles, :through => :personal_roles
  has_many :personal_roles
  has_many :personal_connections
  has_many :locations, :through => :personal_connections, :uniq => true
  has_many :verbs, :through => :personal_connections
  has_many :plaques, :through => :personal_connections, :uniq => true

  before_save :update_index

  scope :no_role, :conditions => {:personal_roles_count => 0}

  DATE_REGEX = /c?[\d]{4}/
  DATE_RANGE_REGEX = /(?:\(#{DATE_REGEX}-#{DATE_REGEX}\)|#{DATE_REGEX}-#{DATE_REGEX})/

  def areas
    areas = []
    locations.each do |location|
      if location.area
        areas << location.area unless areas.include?(location.area)
      end
    end
    return areas
  end

  def self.find_or_create_by_name_and_dates(string)
    name_and_dates_regex = /\A(.*)\s\(?(c?)([\d]{4})-(c?)([\d]{4})\)?\Z/
    if string =~ name_and_dates_regex
      person = find_or_create_by_name(string[name_and_dates_regex, 1])
      unless person.born_on or person.died_on
        person.born_on = Date.parse(string[name_and_dates_regex, 3] + "-01-01")
        if string[name_and_dates_regex, 2] == "c"
          person.born_on_is_circa = true
        end
        person.died_on = Date.parse(string[name_and_dates_regex, 5] + "-01-01")
        if string[name_and_dates_regex, 4] == "c"
          person.died_on_is_circa = true
        end
        person.save!
      end
      return Person.find(person.id)
    else
      find_or_create_by_name(string)
    end
  end

  def self.find_or_create_by_name_and_dates_and_roles(string)

    name_dates_roles_regex = /\A(.*\s#{DATE_RANGE_REGEX}),?\s?(.*)?\Z/
    name_roles_re = /\A([A-Z][a-zA-Z\.,]+(\s(([A-Z][a-z]+|[A-Z]\.|de))|\,\sEarl\sof\s[A-Z][a-z]+)*)((\s|,\s)(.*?))?\Z/

    if string =~ name_dates_roles_regex
      person = find_or_create_by_name_and_dates(string[name_dates_roles_regex, 1])
      person.find_or_create_roles(string[name_dates_roles_regex, 2])
    elsif string =~ name_roles_re
      person = find_or_create_by_name(string[name_roles_re, 1].strip)
      person.find_or_create_roles(string[name_roles_re, 7])
    else
      person = find_or_create_by_name_and_dates(string)
    end
    return person
  end

  def find_or_create_roles(roles)
    if roles
      roles = roles.split(/,?\sand\s|,?\s\&\s|,\s/)
      roles.each do |role|
        role = Role.find_or_create_by_name_and_slug(role, role.downcase.gsub(" ", "_").gsub("-", "_").gsub("'", ""))
        unless self.roles.exists?(role)
          self.roles << role
        end
      end
    end
    return self
  end

  def person?
    true
    false if animal? or thing?
  end

  def animal?
    false
    true if roles.any?{|role| role.animal?}
  end

  def thing?
    false
    true if roles.any?{|role| role.thing?}
  end
  
  def born_in
    born_on.year if born_on
  end
  
  def died_in
    died_on.year if died_on
  end
  
  def dead?
    false
    return true if died_in
    return true if !thing? && born_in < 1900
  end
  
  def alive?
    !dead?
  end
  
  def age
    "unknown"
    return died_in - born_in if died_in && born_in
    return Time.now.year - born_in if born_in && thing?
    return Time.now.year - born_in if born_in && born_in > 1900
   end
  
  def age_in(year)
    return year - born_in if born_in
  end
  
  # note that the Wikipedia url is constructed from the person's name
  # unless it is overridden by data in the wikipedia_url field
  # or the wikipedia_url field is set to blank to indicate that there
  # is no Wikipedia record
  def default_wikipedia_url
    return wikipedia_url if wikipedia_url && wikipedia_url > ""
    untitled_name = name.gsub("Canon ","").gsub("Captain ","").gsub("Cardinal ","").gsub("Dame ","").gsub("Dr ","").gsub("Lord ","").gsub("Sir ","").strip.gsub(/ /,"_")
    "http://en.wikipedia.org/wiki/"+untitled_name
  end

  private

    def update_index
      self.index = self.name[0,1].downcase
      if self.surname_starts_with.blank?
        self.surname_starts_with = self.name[self.name.rindex(" ") ? self.name.rindex(" ") + 1 : 0,1].downcase
      end
      self.surname_starts_with.downcase!
    end

end
