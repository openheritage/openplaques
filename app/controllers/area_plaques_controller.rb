class AreaPlaquesController < ApplicationController

  before_filter :find_area, :only => [:show]
  respond_to :html, :kml, :osm, :xml, :json

  def show
    if (params[:id] && params[:id]=='unphotographed')
      @plaques = @area.plaques.unphotographed
    elsif (params[:id] && params[:id]=='current')
      @plaques = @area.plaques.current
    elsif (params[:id] && params[:id]=='ungeolocated')
      @plaques = @area.plaques.ungeolocated
    else
      @plaques = @area.plaques
    end
    respond_with @plaques do |format|
      format.html { render @plaques }
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.json { render :json => @plaques.as_json() }
    end
  end

  protected

    def find_area
      @country = Country.find_by_alpha2!(params[:country_id])
      @area = @country.areas.find_by_slug!(params[:area_id])
    end

end
