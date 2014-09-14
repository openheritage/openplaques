class CountryPlaquesController < ApplicationController

  before_filter :find_country, :only => [:show]
  respond_to :html, :kml, :osm, :xml, :json

  def show
    if (params[:id] && params[:id]=='unphotographed')
      @plaques = @country.plaques.unphotographed
    elsif (params[:id] && params[:id]=='current')
      @plaques = @country.plaques.current
    elsif (params[:id] && params[:id]=='ungeolocated')
      @plaques = @country.plaques.ungeolocated
    else
      @plaques = @country.plaques
    end
    respond_with @plaques do |format|
      format.html { render @plaques }
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.xml
      format.json { render :json => @plaques.as_json() }
    end
  end

  protected

    def find_country
      @country = Country.find_by_alpha2!(params[:country_id])
    end

end
