class HomepageController < ApplicationController

  # layout "v1"
  
  def index
    @recent_photos = Photo.find(:all, :order => "created_at DESC", :limit => 4)
    @geolocated_plaques_count = Plaque.geolocated.count
    @plaques_count = Plaque.count
    @photographed_plaques_count = Plaque.photographed.count
    @coloured_plaques_count = Plaque.coloured.count
    
    # TODO: This logic should really be refactored into the view.
    if @plaques_count > 0
      @geolocated_plaques_percent = ((@geolocated_plaques_count.to_f / @plaques_count.to_f) * 100).round(1).to_s
      @photographed_plaques_percent = ((@photographed_plaques_count.to_f / @plaques_count.to_f) * 100).round(1).to_s
      @coloured_plaques_percent = ((@coloured_plaques_count.to_f / @plaques_count.to_f) * 100).round(1).to_s
    end
  end

end
