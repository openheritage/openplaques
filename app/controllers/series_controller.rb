class SeriesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy

  def index
    @series = Series.all
  end
  
  def show
    @series = Series.find(params[:id])
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

end
