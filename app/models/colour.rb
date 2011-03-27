# This class represents 'colours', as commonly identified as the main colour on commemorative
# plaques.
# === Attributes
# * +name+ - the colour's common name (eg 'blue'). 
#
# === Associations
# * Plaques - plaques which use this colour.
class Colour < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :plaques

end
