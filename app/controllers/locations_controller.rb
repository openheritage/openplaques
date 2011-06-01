class LocationsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authorisation_required, :except => [:index, :show]

  before_filter :find_location, :only => [:show, :edit, :update]
  
  def index
    @locations = Location.find(:all, :order => :name)
  end
  
  def edit
    @areas = Area.find(:all, :order => :name)   
	  @countries = Country.find(:all) 
  end
  
  def update
    if @location.update_attributes(params[:location])
      redirect_to location_path(@location)
    else
      render :edit
    end

  end
  
  protected

    def find_location
      @location = Location.find(params[:id])      
    end

end
