class PlaquePhotosController < ApplicationController

  before_filter :find_plaque

  protected

    def find_plaque
      @plaque = Plaque.find(params[:plaque_id])
    end

end
