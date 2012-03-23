class PhotosController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_photo, :only => [:destroy, :edit, :show, :update]

  def index
    @photos = Photo.paginate(:page => params[:page], :per_page => 20)
    respond_to do |format|
      format.html
      format.xml # { render :xml => @photo }
      format.json { render :json => @photos }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.xml # { render :xml => @photo }
      format.json { render :json => @photo }
    end
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
    @photo.wikimedia_data
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
    @licences = Licence.all(:order => :name)
  end

  protected

    def find_photo
      @photo = Photo.find(params[:id])
    end

end
