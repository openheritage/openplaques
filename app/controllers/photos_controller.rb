class PhotosController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_photo, :only => [:destroy, :edit, :show, :update]

  def index
    @photos = Photo.find(:all, :limit => 10, :order => "created_at DESC", :offset => params[:offset])
    @photographer_count = Photo.all(:group => "photographer").count
  end

  def update
    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        flash[:notice] = 'Photo was successfully updated.'
        format.html { redirect_to(@photo) }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @photo.errors, :status => :unprocessable_entity }
      end
    end
  end

  def new
    @photo = Photo.new
    @licences = Licence.all(:order => :name)
  end

  def create
    @photo = Photo.new(params[:photo])

    if @photo.save
      redirect_to photo_path(@photo)
    else
      @licences = Licence.all(:order => :name)
      render :new
    end
  end

  def destroy
    @plaque = @photo.plaque

    @photo.destroy
    redirect_to plaque_path(@plaque)
  end
  
  def edit
    @shots = ["1 - extreme close up", "2 - close up", "3 - medium close up", "4 - medium shot", "5 - long shot", "6 - establishing shot"]
  end

  protected

    def find_photo
      @photo = Photo.find(params[:id])
    end

end
