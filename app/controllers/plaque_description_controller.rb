class PlaqueDescriptionController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
  end

  def show
    @plaque = Plaque.find(params[:plaque_id])    
    redirect_to plaque_path(@plaque, :anchor => :description)
  end

end
