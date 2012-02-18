class UnphotographedPlaquesByCountryController < ApplicationController

  def show
    @country = Country.find_by_alpha2!(params[:country_id])
    @plaques = @country.plaques.unphotographed
    @mean = help.find_mean(@plaques)
    @zoom = 7
    respond_to do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.yaml
      format.xml
      format.json { render :json => @plaques }
    end
  end


  protected

    def help
      Helper.instance
    end

    class Helper
      include Singleton
      include PlaquesHelper
    end

end
