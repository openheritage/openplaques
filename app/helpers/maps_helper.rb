module MapsHelper

  def google_maps_path(latitude, longitude, options = {})
    
    width = options[:width] || 300
    height = options[:height] || 300
    colour = options[:colour] || "blue"
    zoom = options[:zoom] || 16
    maptype = options[:maptype] || nil
    
    url = "http://maps.google.com/maps/api/staticmap?"
    params = []
    params << "size=" + width.to_s + "x" + height.to_s
    params << "markers=color:" + colour + "|" + latitude.to_s + "," + longitude.to_s
    params << "sensor=false"
    params << "zoom=" + zoom.to_s
    params << "maptype=" + maptype if maptype
    url + params.join("&")
    
  end

end