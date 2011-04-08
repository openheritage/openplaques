class ColoursController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @colours = Colour.all
    respond_to do |format|
      format.html
      format.kml {
        @parent = @colours
        render :template => "colours/index" 
      }
      format.yaml
      format.xml { render :xml => @colours }
      format.json { render :json => @colours }
    end
  end
  
  def show
    begin
      @colour = Colour.find_by_slug!(params[:id])
    rescue
      @colour = Colour.find(params[:id])
      redirect_to(colour_url(@colour.name), :status => :moved_permanently) and return
    end      

      @plaques = @colour.plaques
#      @centre = find_mean(@plaques)
      @zoom = 9
      respond_to do |format|
        format.html
        format.kml { render :template => "plaques/show" }
        format.yaml
        format.xml  { render :xml => @colour }
        format.json { render :json => @colour }
      end      

  end
  
  def new
    @colour = Colour.new
  end
  
  def create
    @colour = Colour.new(params[:colour])
    
    if @colour.save
      redirect_to colour_path(@colour.slug)
    else
      render :action => :new
    end
  end
  
  def edit
    @colour = Colour.find_by_slug!(params[:id])
  end
  
  def update
    @colour = Colour.find_by_slug!(params[:id])
    old_slug = @colour.slug
    
    if @colour.update_attributes(params[:colour]) 
      redirect_to colour_path(@colour.slug)
    else
      @colour.slug = old_slug
      render :action => :edit
    end

  end


end
