class UnphotographedPlaquesByCountryController < ApplicationController

  def show
    @country = Country.find_by_alpha2!(params[:country_id])
    @plaques = @country.plaques.unphotographed
  end

end
