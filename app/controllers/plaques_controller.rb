class PlaquesController < ApplicationController
  
  before_filter :authenticate_user!, :except => [:index, :show, :map, :new, :create]

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
    if params["box"]
      # Should really do some validation here...
      coords = params["box"][1,params["box"].length-2].split("],[")
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
        conditions[:updated_at] = since..DateTime.now
      end
    end
    
    respond_to do |format|
      format.html {
        @plaques = Plaque.find(:all, :conditions => conditions, :order => :inscription, :include => [{:personal_connections => [{:person => :roles}, :verb, :location]}, :organisation, :location])
        @page_title = "Plaques"
#        @centre = find_mean(@plaques)
        @zoom = 7
      }
      format.kml {
        @plaques = Plaque.geolocated.find(:all, :conditions => conditions)
      }
      format.yaml {
        @plaques = Plaque.find(:all, :conditions => conditions)
      }
      format.xml {
        @plaques = Plaque.find(:all, :conditions => conditions)
      }
      format.json {
        @plaques = Plaque.find(:all, :include => [:language, {:location => {:area => :country}}, :photos, :colour, :organisation], :conditions => conditions)
        render :json => @plaques
      }
      format.bp {
        @plaques = Plaque.geolocated.find(:all, :conditions => conditions, :limit => 20)
      }
      format.rss {
        @plaques = Plaque.geolocated.find(:all, :conditions => conditions)
      }
      format.csv {
        @plaques = Plaque.find(:all, :conditions => conditions)
      }
      format.poi {
        @plaques = Plaque.geolocated.find(:all, :conditions => conditions)
      }
    end
  end

  # GET /plaques/1
  # GET /plaques/1.kml
  # GET /plaques/1.yaml
  # GET /plaques/1.xml
  # GET /plaques/1.json
  # GET /plaques/1.bp
  def show
    @plaque = Plaque.find(params[:id])
    
    @plaques = [@plaque]
    respond_to do |format|
      format.html # show.html.erb
      format.kml
      format.yaml
      format.xml
      format.json {
        render :json => @plaque
      }
      format.bp
    end
  end

  # GET /plaques/new
  # GET /plaques/new.xml
  def new
    
    @plaque = Plaque.new

    @countries = Country.all(:order => :name)    
    @organisations = Organisation.all(:order => :name)    
    @languages = Language.all(:order => :name)
    @common_colours = Colour.common.all(:order => "plaques_count DESC")
    @other_colours = Colour.other.all(:order => :name)

    if !current_user        
      @user = User.new
    end

  end

  # GET /plaques/1/edit
  def edit
    @plaque = Plaque.find(params[:id])
    @organisations = Organisation.find(:all, :order => :name)    
	  @possible_photos = fetch_photos params[:id]
  end

  def parse_inscription
    @plaque = Plaque.find(params[:id])
    @plaque.parse_inscription
    redirect_to edit_plaque_inscription_path(@plaque)
  end
  
  def unparse_inscription
    @plaque = Plaque.find(params[:id])
    @plaque.unparse_inscription
    redirect_to @plaque
  end
  
  def flickr_search
    @plaque = Plaque.find(params[:id])
    help.find_photo_by_machinetag(@plaque)
    redirect_to @plaque
  end
  
  def flickr_search_all
    @plaque = Plaque.find(params[:id])
    help.find_photo_by_machinetag(nil)
    redirect_to @plaque
  end

  # POST /plaques
  # POST /plaques.xml
  def create
    
    @plaque = Plaque.new(params[:plaque])
    
    if current_user
      @plaque.user = current_user
    elsif !params[:user_email].blank? && !params[:user_name].blank?
      user_email = params[:user_email]
      user_name = params[:user_name]
      @user = User.find_by_email(user_email)
      if @user 
        if @user.is_verified
          flash[:notice] = "You are a proper user - you should login first."
          redirect_to login_path and return
        end
      else
        @user = User.new
        @user.email = user_email
        @user.name = user_name
        @user.username = Time.now.to_i.to_s
        @user.password = @user.username
        @user.password_confirmation = @user.password
        @user.is_verified = false
        @user.save!
      end      
      @plaque.user = @user
    end
    
    if @plaque.colour.nil? && params[:other_colour_id]

      @plaque.colour = Colour.find(params[:other_colour_id])
      
    end


    if params[:location] && !params[:location].blank?
      country = Country.find(params[:plaque][:country])
      if params[:area_id] && !params[:area_id].blank?
        area = Area.find(params[:area_id])
        raise "ERROR" if area.country_id != country.id and return
      elsif params[:area] && !params[:area].blank?
        area = country.areas.find_by_name(params[:area])
         unless area
           area = country.areas.create!(:name => params[:area], :slug => params[:area].downcase.gsub(" ", "_"))
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
            
    if params[:photo_url] && !params[:photo_url].blank?
            
    end      
        
    if @plaque.save

      PlaqueMailer.new_plaque_email(@plaque).deliver
      flash[:notice] = "Thanks for adding this plaque."
      redirect_to plaque_path(@plaque)
    else  
      params[:checked] = "true"
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
    @plaque = Plaque.find(params[:id])

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
        format.html { render :action => "edit" }
        format.xml  { render :xml => @plaque.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /plaques/1
  # DELETE /plaques/1.xml
  def destroy
    @plaque = Plaque.find(params[:id])
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
   
end
