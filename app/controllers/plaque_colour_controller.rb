class PlaqueColourController < ApplicationController

  before_filter :authenticate_user!

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @colours = Colour.find(:all, :order => :name)
  end

end
