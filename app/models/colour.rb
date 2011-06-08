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

  validates_presence_of :slug
  validates_uniqueness_of :slug


  has_many :plaques

  scope :common, where(:common => true)
  scope :other, where(:common => false)

end
