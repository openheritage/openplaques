# This class represents featured plaques, e.g. 'plaque of the day'
# It should hold enough information to be able to rotate the plaque featured
# on the home page to something topical and/or interesting
# === Attributes
# * +description+ - a short blurb on why this one was chosen
# * +feature_on+ - (optional) a specific date to show this plaque, e.g. someone's birthday
# * +last_featured+ - when the plaque was last featured
# * +featured_count+ - number of times the plaque has been featured
#
# === Associations
# * Plaque - the plaque to feature
class Pick < ActiveRecord::Base

  belongs_to :plaque
  
  validates_presence_of :plaque_id
  validates_uniqueness_of :plaque_id
  
end
