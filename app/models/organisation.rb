# This class represents an organisation entity which has been responsible for erecting
# commemorative plaques. Famous examples include 'English Heritage' - other examples may be
# civic societies or local councils.
# === Attributes
# * +name+ - The official name of the organisation
# * +slug+ - An identifier for the organisation, usually equivalent to its name in lower case, with spaces replaced by underscores. Used in URLs.
# * +description+ - A textual description
# === Associations
# * Plaques - plaques erected by this organisation.
class Organisation < ActiveRecord::Base

  before_validation :make_slug_not_war
  validates_presence_of :name, :slug
  validates_uniqueness_of :slug

  has_many :sponsorships
  has_many :plaques, :through => :sponsorships

  scope :name_starts_with, lambda {|term| where(["lower(name) LIKE ?", term.downcase + "%"]) }
  scope :name_contains, lambda {|term| where(["lower(name) LIKE ?", "%" + term.downcase + "%"]) }
  scope :most_plaques_order, order("plaques_count DESC")

  include ApplicationHelper

  def as_json(options={})
    super(:only => [:name, :id])
  end

  private

end
