class HomepageController < ApplicationController

  def index
    @plaques_count = Plaque.count
    @recent_plaques = Plaque.photographed.order("created_at DESC").limit(2)
    
    # use today's plaque
    @todays = Pick.find(:first, :conditions => ["last_featured > ? and last_featured < ?", Date.today, Date.today + 1.day], :order => "last_featured DESC")   
    if @todays.nil?
      # otherwise see if one has been set for today, e.g. because it's the subject's birthday
      @todays = Pick.find(:first, :conditions => ["feature_on > ? and feature_on < ?", Date.today, Date.today + 1.day])
      if @todays.nil?
        # otherwise get the least featured
        @todays = Pick.find(:first, :order => "featured_count ASC")
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
  end

end
