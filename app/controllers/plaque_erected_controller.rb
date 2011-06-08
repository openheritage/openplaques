class PlaqueErectedController < ApplicationController

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @organisations = Organisation.find(:all, :order => :name)
  end

end
