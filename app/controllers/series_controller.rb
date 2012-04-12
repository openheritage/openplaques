class SeriesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy

  def index
    @series = Series.all
  end
  
  def edit
    @series = Series.find(params[:id])
  end  

  def show
    @series = Series.find(params[:id])
    @plaques = @series.plaques
    @mean = help.find_mean(@plaques)
    respond_to do |format|
      format.html # show.html.erb
      format.kml { render "plaques/index" }
      format.yaml
      format.xml { render "plaques/index" }
      format.json {
        render :json => @series.plaques
      }
    end
  end

  def new
    @series = Series.new
  end

  def create
    @series = Series.new(params[:series])
    if @series.save
      redirect_to series_path(@series)
    end
  end

  def update
    if @series.update_attributes(params[:series])
      redirect_to series_path(@series)
    else
      render :edit
    end
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include PlaquesHelper
  end
  
end
