# A verb that connects a person with a location, eg 'lived', 'worked' or 'played'.
#
# === Attributes
# * +name+ - The name of the verb, in past tense, eg 'lived'.
#
# === Associations
# * +plaques+ - The plaques on which this verb is used.
# * +people+ - The people associated with this verb.
# * +locations+ - The locations associated with this verb.
# * +personal_connections+ - The personal connections (joining model) which connect with this verb.
class Verb < ActiveRecord::Base

  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :personal_connections
  has_many :plaques, :through => :personal_connections
  has_many :people, :through => :personal_connections
  has_many :locations, :through => :personal_connections
  
  def find_or_create_by_past_tense_name(verb)
    
  end
  
end
