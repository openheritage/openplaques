class PlaqueLocationController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
  end

end
