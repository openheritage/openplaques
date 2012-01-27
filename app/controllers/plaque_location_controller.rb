class PlaqueLocationController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    if !@plaque.location
      @plaque.location = Location.new(:name => "?")
    end
  end

end
