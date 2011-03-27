class LicencesController < ApplicationController

  before_filter :authorisation_required, :except => [:index, :show]

  def index
    @licences = Licence.find(:all)
  end
  
  def show
    @licence = Licence.find(params[:id])
  end

end
