class CountriesController < ApplicationController

  layout "v1"

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @countries = Country.all(:order => :name)
  end
  
  def new
    @country = Country.new
  end
  
  def create
    @country = Country.new(params[:country])
    
    if @country.save
      redirect_to country_path(@country)
    else
      render :new
    end
  end
  
  def show
    begin
      @country = Country.find_by_alpha2!(params[:id])
    rescue
      @country = Country.find(params[:id])
      redirect_to(country_url(@country.alpha2), :status => :moved_permanently)
    end

    @areas = @country.areas.all(:order => :name, :include => :country)

  end
  
  def edit
    @country = Country.find_by_alpha2(params[:id])
  end
      
  def update
    @country = Country.find_by_alpha2(params[:id])
    
    if @country.update_attributes(params[:country])
      redirect_to country_path(@country)
    else
      render :edit
    end
  end

end
