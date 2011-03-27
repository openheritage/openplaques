class UnphotographedPlaquesByAreaController < ApplicationController

  def show
    @country = Country.find_by_alpha2(params[:country_id])
    @area = @country.areas.find_by_slug(params[:area_id])
	if @area
		@plaques = @area.plaques.unphotographed
	end
    if @plaques
#		@centre = find_mean(@plaques)
		@zoom = 11
    end
  end

end
