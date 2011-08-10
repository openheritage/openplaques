module CountriesHelper


  def country_unphotographed_path(country, options = {})
    url_for(options.merge(:controller => :unphotographed_plaques_by_country, :action => :show, :country_id => country.alpha2))
  end

end
