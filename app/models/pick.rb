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
  
  def self.todays
    # use today's plaque if one has already been chosen
    @todays = Pick.find(:first, :conditions => ["last_featured > ? and last_featured < ?", Date.today, Date.today + 1.day], :order => "last_featured DESC")   
    if @todays.nil?
      # otherwise see if one would like to be displayed today, e.g. because it's the subject's birthday
      @todays = Pick.find(:first, :conditions => ["feature_on > ? and feature_on < ?", Date.today, Date.today + 1.day])
      if @todays.nil?
        # otherwise get the least featured, but not yesterday's pick
        @todays = Pick.find(:first, :conditions => ["last_featured isnull or last_featured < ?", Date.today - 1.day], :order => "featured_count ASC")
      end
      if @todays
        # great, you chose one, so make it today's pick
        @todays.last_featured = DateTime.now
        if @todays.featured_count == nil
          @todays.featured_count = 0
        end
        @todays.featured_count = @todays.featured_count + 1
        @todays.save
      end
    end
    return @todays
  end
  
end
