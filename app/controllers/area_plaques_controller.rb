class AreaPlaquesController < ApplicationController

  before_filter :find_area, :only => [:show]
  respond_to :html, :kml, :osm, :xml, :json

  def show
    @display = 'all'
    if (params[:id] && params[:id]=='unphotographed')
      @plaques = @area.plaques.unphotographed.paginate(:page => params[:page], :per_page => 50)
      @display = 'unphotographed'
    elsif (params[:id] && params[:id]=='current')
      @plaques = @area.plaques.current.paginate(:page => params[:page], :per_page => 50)
    elsif (params[:id] && params[:id]=='ungeolocated')
      @plaques = @area.plaques.ungeolocated.paginate(:page => params[:page], :per_page => 50)
      @display = 'ungeolocated'
    else
      @plaques = @area.plaques.paginate(:page => params[:page], :per_page => 50)
    end
    respond_with @plaques do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.xml
      format.json { render :json => @plaques.as_json() }
    end
  end

  protected

    def find_area
      @country = Country.find_by_alpha2!(params[:country_id])
      @area = @country.areas.find_by_slug!(params[:area_id])
    end

end
