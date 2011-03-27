# This class represents content licences, such as those produced by the Creative Commons
# organisation.
# === Attributes
# * +name+ - the licence's full name
# * +url+ - a permanent URL at which the licence.
#
# === Associations
# * Plaques - plaques which are mainly written in this language.
class Licence < ActiveRecord::Base

  validates_presence_of :name, :url
  validates_uniqueness_of :url

  has_many :photos

end
