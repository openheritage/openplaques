class CountryPlaquesController < ApplicationController

  before_filter :find_country, :only => [:show]
  respond_to :json

  def show
    @plaques = @country.plaques
    respond_with @plaques do |format|
      format.html { render @plaques }
      format.json { render :json => @plaques.as_json(
        :only => [:id, :latitude, :longitude, :inscription],
        :methods => [:title, :uri, :colour_name]
        ) 
      }
    end
  end

  protected

    def find_country
      @country = Country.find_by_alpha2!(params[:country_id])
    end

end
