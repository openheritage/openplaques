module AreasHelper
  
  def area_path(area, options = {})
    url_for(options.merge(:controller => :areas, :action => :show, :id => area.slug, :country_id => area.country.alpha2))
  end

  def area_url(area, options = {})
    area_path(area, options.merge!(:only_path => false))
  end

  def edit_area_path(area, options = {})
    url_for(options.merge(:controller => :areas, :action => :edit, :id => area.slug, :country_id => area.country.alpha2))
  end

  def area_unphotographed_path(area, options = {})
    url_for(options.merge(:controller => :unphotographed_plaques_by_area, :action => :show, :area_id => area.slug, :country_id => area.country.alpha2))
  end


end
