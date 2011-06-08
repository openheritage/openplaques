class AreasController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_country, :only => [:index, :new, :show, :create, :edit, :update]
  before_filter :find_area, :only => [:show, :edit, :update]

  def index
    @areas = @country.areas.all(:order => :name)
    respond_to do |format|
      format.html
      format.kml {
        @parent = @areas
        render "colours/index"
      }
      format.yaml
      format.xml { render :xml => @areas }
      format.json { render :json => @areas }
    end
  end

  def new
    @area = @country.areas.new
  end

  def show

    @plaques = @area.plaques
    if @plaques
      #  @centre = find_mean(@plaques)
      @zoom = 11
    end

    respond_to do |format|
      format.html
      format.kml { render "plaques/show" }
      format.yaml
      format.xml { render :xml => @area }
      format.json { render :json => @area }
    end
  end

  def create
    @area = @country.areas.new(params[:area])

    if @area.save
      redirect_to country_area_path(@area.country_alpha2, @area.slug)
    else
      render :new
    end
  end

  # DELETE /areas/1
  def destroy
    @area = Area.find(params[:id])
    if (@area.plaques != nil)
      # should we block this if there are plaques?
    end
    @area.destroy
    redirect_to(areas_url)
  end

  def edit
    @countries = Country.find(:all)
  end

  def update

    if @area.update_attributes(params[:area])
      flash[:notice] = 'Area was successfully updated.'
      redirect_to(country_area_path(@area.country.alpha2, @area.slug))
    else
      @countries = Country.all
      render "edit"
    end
  end

  protected

    def find_country
      @country = Country.find_by_alpha2!(params[:country_id])
    end

    def find_area
      @area = @country.areas.find_by_slug!(params[:id])
    end

end
