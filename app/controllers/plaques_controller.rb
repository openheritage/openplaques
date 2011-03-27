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
    
    if current_user
      @plaque = Plaque.new
      @colours = Colour.all(:order => :name)
      @organisations = Organisation.all(:order => :name)    
      @areas = Area.all(:order => :name)
      @languages = Language.all(:order => :name)


      respond_to do |format|
        format.html # new.html.erb
        format.xml  { render :xml => @plaque }
      end
    else
      @countries = Country.all(:order => :name)    

      @user = User.new
      
      @plaque = Plaque.new

      respond_to do |format|
        format.html {render :new_logged_out}
      end
      
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
    
    if current_user
    
      @plaque = Plaque.new(params[:plaque])

      if params[:location] && params[:area] && !params[:area][:id].blank? 
        @area = Area.find(params[:area][:id])
      
        @location = Location.find_or_create_by_name_and_area_id(params[:location], @area.id)
        @plaque.location = @location    
      end
    
      @plaque.user = current_user
      
      respond_to do |format|
        if @plaque.save
          flash[:notice] = 'Plaque was successfully created.'
          format.html { redirect_to(@plaque) }
          format.xml  { render :xml => @plaque, :status => :created, :location => @plaque }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @plaque.errors, :status => :unprocessable_entity }
        end
      end
  
    else

      @user = User.find_by_email(params[:plaque][:user][:email])

      if @user && @user.is_verified
          flash[:notice] = "You are a proper user - you should login first."
          redirect_to login_path
      else

        unless @user
          @user = User.new
          @user.email = params[:plaque][:user][:email]
          @user.name = params[:plaque][:user][:name]
          @user.username = Time.now.to_i.to_s
          @user.password = @user.username
          @user.password_confirmation = @user.password
          @user.is_verified = false
          @user.save!
        end 
      
        @plaque = @user.plaques.new
        @plaque.inscription = params[:plaque][:inscription]
      
        if @plaque.save
      
          PlaqueMailer.new_plaque_email(@plaque).deliver
        
          flash[:notice] = "Thanks for adding this plaque."
          redirect_to plaque_path(@plaque)
        else
          
          render :new
          
        end
      
      end  
  
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
  	# Store the selected photo (if any)
  	# TODO this doesn't work yet..
#  	if (params[:photo] != nil)
#  		fetch_photos(params[:id]).each do |p|
#  			if (p.url == params[:photo])
#  				@photo = Photo.new		
#  				@photo.plaque = @plaque
#          @photo.file_url = photo.url		
#          @photo.url = photo_url
#        		
#  				@photo.save!
#  			end
#  		end
#  	end
    
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
