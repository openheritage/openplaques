# This class represents an organisation entity which has been responsible for erecting
# commemorative plaques. Famous examples include 'English Heritage' - other examples may be
# civic societies or local councils.
# === Attributes
# * +name+ - The official name of the organisation
# * +slug+ - An identifier for the organisation, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
# === Associations
# * Plaques - plaques erected by this organisation.
class Organisation < ActiveRecord::Base

  before_validation :make_slug_not_war
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  has_many :plaques

  scope :name_starts_with, lambda {|term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :most_plaques_order, order("plaques_count DESC")

  def as_json(options={})
    super(:only => [:name, :id])
  end
  
  private
    def make_slug_not_war
      self.slug = (self.slug.blank? ? self.name : self.slug).rstrip.lstrip.downcase.gsub(" ", "_").gsub("-", "_").gsub(",", "_")
    end

end
