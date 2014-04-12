class PlaquesController < ApplicationController

  before_filter :authenticate_user!, :only => :edit
  before_filter :authenticate_admin!, :only => :destroy

  before_filter :find_plaque, :only => [:show, :parse_inscription, :unparse_inscription, :flickr_search, :flickr_search_all, :update, :destroy, :edit]
#	before_filter :set_cache_header, :only => :index
#  after_filter :set_access_control_headers, :only => :index

  respond_to :html, :xml, :json, :kml, :poi, :rss, :csv

  # box = top_left, bottom_right
  # e.g. http://0.0.0.0:3000/plaques?box=[52.00,-1],[50.00,0.01]
  # or map tile http://0.0.0.0:3000/plaques/12/2046/1374.json to match http://a.tile.openstreetmap.org/12/2046/1374.png
  # GET /plaques
  # GET /plaques.kml
  # GET /plaques.xml
  # GET /plaques.json
  # GET /plaques.rss
  # GET /plaques.csv
  # GET /plaques.poi
  def index
    conditions = {}

    if params[:box]
      # TODO: Should really do some validation here...
      coords = params[:box][1,params[:box].length-2].split("],[")
      top_left = coords[0].split(",")
      bottom_right = coords[1].split(",")
      conditions[:latitude] = bottom_right[0].to_s..top_left[0].to_s
      conditions[:longitude] = top_left[1].to_s..bottom_right[1].to_s
    end

    if params[:since]
      since = DateTime.parse(params[:since])
      now = DateTime.now
      if since && since < now
        since = since + 1.second
        conditions[:updated_at] = since..now
      end
    end

    if params[:limit] && params[:limit].to_i <= 2000
      limit = params[:limit]
    elsif params[:limit]
      limit = 2000
    else
      limit = 20
    end

    zoom = params[:zoom].to_i
    if zoom > 0
      x = params[:x].to_i
      y = params[:y].to_i
      @plaques = Plaque.tile(zoom, x, y)
    elsif params[:data] && params[:data] == "simple"
      @plaques = Plaque.all(:conditions => conditions, :order => "created_at DESC", :limit => limit)
    elsif params[:data] && params[:data] == "basic"
      @plaques = Plaque.all(:select => [:id, :latitude, :longitude, :inscription])
    else
      @plaques = Plaque.all(:conditions => conditions, :order => "created_at DESC", :limit => limit, :include => [:language, :organisations, :colour, [:location => [:area => :country]]])
    end

    respond_with @plaques do |format|
      format.json {
        if params[:data] && params[:data] == "simple"
          render :json => @plaques.as_json(:only => [:id, :latitude, :longitude, :inscription],
            :methods => [:title, :colour_name, :machine_tag, :thumbnail_url])
        elsif params[:data] && params[:data] == "basic"
          render :json => @plaques.as_json(:only => [:id, :latitude, :longitude, :inscription]) 
        else
          render :json => { 
            type: 'FeatureCollection',
            features: @plaques.as_json
          }
        end
      }
    end
  end

  # GET /plaques/1
  # GET /plaques/1.kml
  # GET /plaques/1.xml
  # GET /plaques/1.json
  def show
    @plaques = [@plaque]
    set_meta_tags :open_graph => {
      :type  => :website,
      :url   => url_for(:only_path=>false),
      :image => @plaque.main_photo ? @plaque.main_photo.file_url : view_context.root_url[0...-1] + view_context.image_path("openplaques-icon.png"),
      :title => @plaque.title,
      :description => @plaque.inscription,
    }
    respond_to do |format|
      format.html
      format.kml { render "plaques/index" }
      format.xml { render "plaques/index" }
      format.json {
        render :json => @plaque.as_json
      }
      format.csv { render "plaques/index" }
    end
  end

  # GET /plaques/new
  # GET /plaques/new.xml
  def new
    @plaque = Plaque.new(:language_id => 1)
    @plaque.build_user
    @plaque.photos.build
    @countries = Country.all(:order => :name)
    @languages = Language.all(:order => :name)
    @common_colours = Colour.common.all(:order => "plaques_count DESC")
    @other_colours = Colour.uncommon.all(:order => :name)
    if !current_user
      @user = User.new
    end
  end

  def flickr_search
    help.find_photo_by_machinetag(@plaque, nil)
    redirect_to @plaque
  end

  def flickr_search_all
    help.find_photo_by_machinetag(nil, nil)
    redirect_to @plaque
  end

  # POST /plaques
  # POST /plaques.xml
  def create
    @plaque = Plaque.new(params[:plaque])

    if current_user
      @plaque.user = current_user
    end

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
        area = country.areas.create!(:name => params[:area])
      end
    end
    if area
      if params[:location] && !params[:location].blank?
        location = area.locations.create!(:name => params[:location])
      else
        location = area.locations.create!(:name => "?")
      end
      @plaque.location = location if location
    end

    unless params[:organisation_name].empty?
      organisation = Organisation.find_or_create_by_name(params[:organisation_name])
      @plaque.organisations << organisation if organisation.valid?
    end

    if @plaque.save
#      PlaqueMailer.new_plaque_email(@plaque).deliver rescue puts "ERROR: mailer didn't work"
      flash[:notice] = "Thanks for adding this plaque."
      redirect_to plaque_path(@plaque)
    else
      params[:checked] = "true"
      @plaque.photos.build if @plaque.photos.size == 0
      @countries = Country.all(:order => :name)
      @languages = Language.all(:order => :name)
      @common_colours = Colour.common.all(:order => "plaques_count DESC")
      @other_colours = Colour.uncommon.all(:order => :name)
      render :new
    end
  end

  # PUT /plaques/1
  # PUT /plaques/1.xml
  def update
    if !params[:streetview_url].blank?
      lat = params[:streetview_url][/cbll=+([^,]*)/,1]
      lon = params[:streetview_url][/cbll=[\d|.|-]*,+([\d|.|-]*)&/,1]
      if !lat.blank? && !lon.blank?
        params[:plaque][:latitude] = lat
        params[:plaque][:longitude] = lon
      end
      puts params[:plaque][:latitude]
      puts params[:plaque][:longitude]
    end

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
  
  def edit
    if @plaque.location.blank?
      @plaque.location = Location.new(:name => "?")
      @plaque.save
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
