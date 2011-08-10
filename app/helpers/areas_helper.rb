module AreasHelper

  def area_path(area, options = {})
    country_area_path(area.country, area, options)
  end

  def area_url(area, options = {})
    country_area_url(area.country, area, options)
  end

  def edit_area_path(area, options = {})
    url_for(options.merge(:controller => :areas, :action => :edit, :id => area.slug, :country_id => area.country.alpha2))
  end

  def area_unphotographed_path(area, options = {})
    url_for(options.merge(:controller => :unphotographed_plaques_by_area, :action => :show, :area_id => area.slug, :country_id => area.country.alpha2))
  end

  def list_of_area_links(areas)
    links = []
    areas.each do |area|
      links << link_to(area.name, area_path(area))
    end
    links.to_sentence.html_safe
  end


end
