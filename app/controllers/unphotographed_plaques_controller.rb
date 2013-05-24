class UnphotographedPlaquesController < ApplicationController

	before_filter :set_cache_header
  after_filter :set_access_control_headers

  respond_to :json

  def show
		@plaques = Plaque.unphotographed.select([:id, :latitude, :longitude, :inscription])
	
		respond_with @plaques do |format|
			format.json do
				render :json => @plaques.as_json(:only => [:id, :latitude, :longitude, :inscription])
			end
		end

  end

end
