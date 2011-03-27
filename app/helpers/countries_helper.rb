module CountriesHelper

  def country_path(country, options = {})
    url_for(options.merge(:controller => :countries, :action => :show, :id => country.alpha2))
  end

  def country_url(country, options = {})
    country_path(country, options.merge!(:only_path => false))
  end

  def country_unphotographed_path(country, options = {})
    url_for(options.merge(:controller => :unphotographed_plaques_by_country, :action => :show, :country_id => country.alpha2))
  end

end
