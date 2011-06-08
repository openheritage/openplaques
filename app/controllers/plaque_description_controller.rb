class PlaqueDescriptionController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_plaque

  def show
    redirect_to plaque_path(@plaque, :anchor => :description)
  end

  protected

  def find_plaque
    @plaque = Plaque.find(params[:plaque_id])
  end

end
