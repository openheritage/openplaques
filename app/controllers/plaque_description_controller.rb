class PlaqueDescriptionController < ApplicationController

  before_filter :authenticate_user!

  def edit
    @plaque = Plaque.find(params[:plaque_id])
  end

  def show
    @plaque = Plaque.find(params[:plaque_id])    
    redirect_to plaque_path(@plaque, :anchor => :description)
  end

end
