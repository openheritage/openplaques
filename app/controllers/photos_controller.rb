class PhotosController < ApplicationController

  before_filter :authorisation_required, :except => [:index, :show]

  def index
    @photos = Photo.find(:all, :limit => 10, :order => "created_at DESC", :offset => params[:offset])
	  @photographer_count = Photo.all(:group => "photographer").count
  end
  
  def show
    @photo = Photo.find(params[:id])
  end

  def edit
    @photo = Photo.find(params[:id])
  end
  
  def update
    @photo = Photo.find(params[:id])

    respond_to do |format|
      if @photo.update_attributes(params[:photo])
        flash[:notice] = 'Photo was successfully updated.'
        format.html { redirect_to(@photo) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
      render :action => :new
    end
  end
  
  def destroy
    @photo = Photo.find(params[:id])
    @plaque = @photo.plaque
    
    @photo.destroy
    redirect_to plaque_path(@plaque)
  end
  
end
