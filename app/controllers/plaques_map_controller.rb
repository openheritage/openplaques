class PlaquesMapController < ApplicationController

  def show
    conditions = ""
    if params["box"]
      coords = params["box"][1,params["box"].length-2].split("],[")
      top_left = coords[0].split(",")
      bottom_right = coords[1].split(",")
      conditions = ["latitude <= ? and longitude >= ? and latitude >= ? and longitude <= ?", top_left[0].to_s, top_left[1].to_s, bottom_right[0].to_s, bottom_right[1].to_s]
    end
    @plaques = Plaque.geolocated.find(:all, :conditions => conditions)
  end

end
