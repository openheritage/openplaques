class LocationsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authorisation_required, :except => [:index, :show]

  def show
    @location = Location.find(params[:id])
  end
  
  def index
    @locations = Location.find(:all, :order => :name)
  end
  
  def edit
    @location = Location.find(params[:id])
    @areas = Area.find(:all, :order => :name)   
	@countries = Country.find(:all) 
  end
  
  def update
    @location = Location.find(params[:id])

    if @location.update_attributes(params[:location])
      redirect_to location_path(@location)
    else
      render :action => :edit
    end

  end

end
