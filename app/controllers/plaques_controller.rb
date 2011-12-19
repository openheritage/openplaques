class PlaquesController < ApplicationController

  before_filter :authenticate_user!, :only => :edit
  before_filter :authenticate_admin!, :only => :destroy

  before_filter :find_plaque, :only => [:show, :parse_inscription, :unparse_inscription, :flickr_search, :flickr_search_all, :update, :destroy, :edit]

  respond_to :html, :xml, :json, :kml, :poi, :rss, :csv, :yaml

  def map
    @plaques = Plaque.find(:all, :conditions => ["latitude IS NOT NULL"])
#    @centre = find_mean(@plaques)
    respond_to do |format|
      format.html
      format.rss
    end
  end

  # box = [52.34,-1.23],[50.00,-1.00]
  # box = top_left, bottom_right
  # e.g. http://0.0.0.0:3000/plaques?box=[52.00,-1],[50.00,0.01]
  # GET /plaques
  # GET /plaques.kml
  # GET /plaques.yaml
  # GET /plaques.xml
  # GET /plaques.json
  # GET /plaques.bp
  # GET /plaques.rss
  # GET /plaques.csv
  # GET /plaques.poi
  def index
    conditions = {}

    # Bounding-box query
    if params["box"]
      # Should really do some validation here...
      coords = params["box"][1,params["box"].length-2].split("],[")
      top_left = coords[0].split(",")
      bottom_right = coords[1].split(",")
      conditions[:latitude] = bottom_right[0].to_s..top_left[0].to_s
      conditions[:longitude] = top_left[1].to_s..bottom_right[1].to_s
    end

    # Since query
    if params[:since]
      since = DateTime.parse(params[:since])
      now = DateTime.now
      if since && since < now
        since = since + 1.second
        conditions[:updated_at] = since..DateTime.now
      end
    end

    if params[:limit] && params[:limit].to_i < 100
      limit = params[:limit]
    else
      limit = 20
    end

    @plaques = Plaque.all(:conditions => conditions, :order => "created_at DESC", :limit => limit, :include => [:language, :organisation, :colour, [:location => [:area => :country]]])

    respond_with @plaques

  end

  # GET /plaques/1
  # GET /plaques/1.kml
  # GET /plaques/1.yaml
  # GET /plaques/1.xml
  # GET /plaques/1.json
  # GET /plaques/1.bp
  def show
    @plaques = [@plaque]
    respond_to do |format|
      format.html # show.html.erb
      format.kml { render "plaques/index" }
      format.yaml
      format.xml
      format.json {
        render :json => @plaque
      }
    end
  end

  # GET /plaques/new
  # GET /plaques/new.xml
  def new

    @plaque = Plaque.new
    @plaque.build_user
    @plaque.photos.build

    @countries = Country.all(:order => :name)
    @organisations = Organisation.all(:order => :name)
    @languages = Language.all(:order => :name)
    @common_colours = Colour.common.all(:order => "plaques_count DESC")
    @other_colours = Colour.other.all(:order => :name)

    if !current_user
      @user = User.new
    end

  end

  def parse_inscription
    @plaque.parse_inscription
    redirect_to edit_plaque_inscription_path(@plaque)
  end

  def unparse_inscription
    @plaque.unparse_inscription
    redirect_to @plaque
  end

  def flickr_search
    help.find_photo_by_machinetag(@plaque)
    redirect_to @plaque
  end

  def flickr_search_all
    help.find_photo_by_machinetag(nil)
    redirect_to @plaque
  end

  # POST /plaques
  # POST /plaques.xml
  def create
    @plaque = Plaque.new(params[:plaque])

    if current_user
      @plaque.user = current_user
    end
    
    if params[:location] && !params[:location].blank?
      country = Country.find(params[:plaque][:country].blank? ? 1 : params[:plaque][:country])
      if params[:area_id] && !params[:area_id].blank?
        area = Area.find(params[:area_id])
        raise "ERROR" if area.country_id != country.id and return
      elsif params[:area] && !params[:area].blank?
        area = country.areas.find_by_name(params[:area])
        unless area
          area = country.areas.find_by_slug(params[:area].rstrip.lstrip.downcase.gsub(" ", "_"))
        end
        unless area
          area = country.areas.create!(:name => params[:area], :slug => params[:area].rstrip.lstrip.downcase.gsub(" ", "_"))
        end
      end

      if area
        location = area.locations.find_by_name(params[:location])
        unless location
          location = area.locations.create!(:name => params[:location])
        end
      end
    end

    @plaque.location = location if location

    if @plaque.save

      PlaqueMailer.new_plaque_email(@plaque).deliver
      flash[:notice] = "Thanks for adding this plaque."
      redirect_to plaque_path(@plaque)
    else
      params[:checked] = "true"
      @plaque.photos.build if @plaque.photos.size == 0

      @countries = Country.all(:order => :name)
      @organisations = Organisation.all(:order => :name)
      @languages = Language.all(:order => :name)
      @common_colours = Colour.common.all(:order => "plaques_count DESC")
      @other_colours = Colour.other.all(:order => :name)

      render :new
    end

  end

  # PUT /plaques/1
  # PUT /plaques/1.xml
  def update
    if params[:location]
      unless @plaque.location && params[:location] == @plaque.location.name
        if @plaque.location && @plaque.location.plaques_count == 1
          @plaque.location.update_attributes(:name => params[:location])
        else
          @location = Location.find_or_create_by_name(params[:location])
          @plaque.location = @location
        end
      end
    end

    if params[:plaque] && params[:plaque][:colour_id]
      @colour = Colour.find(params[:plaque][:colour_id])
      if @plaque.colour_id != @colour.id
        @plaque.colour = @colour
        @plaque.save
      end
    end
    respond_to do |format|
      if @plaque.update_attributes(params[:plaque])
        flash[:notice] = 'Plaque was successfully updated.'
        format.html { redirect_to(@plaque) }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @plaque.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /plaques/1
  # DELETE /plaques/1.xml
  def destroy
    @plaque.destroy

    respond_to do |format|
      format.html { redirect_to(plaques_url) }
      format.xml  { head :ok }
    end
  end

  def help
    Helper.instance
  end

  class Helper
    include Singleton
    include PlaquesHelper
  end

  protected

    def find_plaque
      @plaque = Plaque.find(params[:id])
    end

end
