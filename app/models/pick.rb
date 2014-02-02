# This class represents featured plaques, e.g. 'plaque of the day'
# It should hold enough information to be able to rotate the plaque featured
# on the home page to something topical and/or interesting
# === Attributes
# * +description+ - a short blurb on why this one was chosen
# * +feature_on+ - (optional) a specific date to show this plaque, e.g. someone's birthday
# * +last_featured+ - when the plaque was last featured
# * +featured_count+ - number of times the plaque has been featured
# * +proposer+ - who to say proposed it
#
# === Associations
# * Plaque - the plaque to feature
class Pick < ActiveRecord::Base

  belongs_to :plaque
  
  validates_presence_of :plaque_id
  validates_uniqueness_of :plaque_id
  
  def self.todays
    # use today's plaque if one has already been chosen
    # avoid picking a pick set for a future date
    @todays = Pick.find(:first, :conditions => ["last_featured > ? and last_featured < ?", (Date.today - 1.day).strftime + " 23:59:59 UTC" , (Date.today + 1.day).strftime + " 00:00:00 UTC"], :order => "last_featured DESC")   
    self.rotate unless @todays
    @todays = Pick.find(:first, :conditions => ["last_featured > ? and last_featured < ?", (Date.today - 1.day).strftime + " 23:59:59 UTC" , (Date.today + 1.day).strftime + " 00:00:00 UTC"], :order => "last_featured DESC")   
    return @todays
  end
  
  def self.rotate
    # see if one would particularly like to be displayed today, e.g. because it's the subject's birthday
    @todays = Pick.find(:first, :conditions => ["feature_on > ? and feature_on < ?", (Date.today - 1.day).strftime + " 23:59:59 UTC" , (Date.today + 1.day).strftime + " 00:00:00 UTC"])
    if @todays.nil?
      # get the least featured, ignoring already featured this week or one destined for a particular day
      @todays = Pick.find(:first, :conditions => ["feature_on isnull and (last_featured isnull or last_featured < ?)", Date.today - 1.week], :order => "featured_count ASC")
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

  def title
    "Pick #" + self.id.to_s + " " + self.plaque.title
  end
  
end
