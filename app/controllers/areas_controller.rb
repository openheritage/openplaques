class AreasController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_country, :only => [:index, :new, :show, :create, :edit, :update, :destroy]
  before_filter :find_area, :only => [:show, :edit, :update, :destroy]

  def index
    @areas = @country.areas.all(:order => :name)
    respond_to do |format|
      format.html
      format.kml {
        @parent = @areas
        render "plaques/index"
      }
      format.yaml
      format.xml # { render :xml => @areas }
      format.json { render :json => @areas }
    end
  end

  def new
    @area = @country.areas.new
  end

  def show
    @plaques = @area.plaques.paginate(:page => params[:page], :per_page => 100)
    if @plaques
      #  @centre = find_mean(@plaques)
      @zoom = 11
    end
    respond_to do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.yaml
      format.xml # { render :xml => @area }
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

  # DELETE /areas/aa
  def destroy
    @area.destroy
    redirect_to country_path(@country)
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
