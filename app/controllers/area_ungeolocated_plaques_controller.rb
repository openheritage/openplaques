class AreaUngeolocatedPlaquesController < ApplicationController

  def show
    @country = Country.find_by_alpha2!(params[:country_id])
    @area = @country.areas.find_by_slug!(params[:area_id])
    @plaques = @area.plaques.ungeolocated.all
  end

end
