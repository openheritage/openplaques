module LocationsHelper

  def location_if_known(plaque)
    if plaque.location
      address(plaque.location)
    else
      unknown()
    end
  end  

  def address(location)
    if location.area
      return (location.name + ", " + link_to(location.area.name, location.area)).html_safe
    else
      link_to location.name, location
    end
  end

  
end
