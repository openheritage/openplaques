# This class represents natural languages, as defined by the ISO code.
# === Attributes
# * +name+ - the language's common name
# * +alpha2+ - 2-letter code as defined by the ISO standard. Used in URLs.
#
# === Associations
# * Plaques - plaques which are mainly written in this language.
class Language < ActiveRecord::Base

  validates_presence_of :name, :alpha2
  validates_uniqueness_of :alpha2
  validates_uniqueness_of :name # Unlikely there will be two languages with the same name.
  validates_format_of :alpha2, :with => /^[a-z]{2}$/, :message => "must be a 2 letter code"

  has_many :plaques
  
  def to_param
    alpha2
  end
  
  def to_s
    name
  end

end
