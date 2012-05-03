class PhotographersController < ApplicationController

  def index
    @photographers = Photo.count(:photographer, :group => 'photographer')
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @photographers }
    end
  end

  def show
    @photographer = Photographer.new
    @photographer.id = params[:id]
    @photos = Photo.find(:all, :conditions => {:photographer => @photographer.id})
    if @photos.length == 0
      @photographer.id = params[:id].gsub(/\_/,'.')
      @photos = Photo.find(:all, :conditions => {:photographer => @photographer.id})
    end
    @photographer.photos = @photos
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @photographer }
    end
  end

  def new
  end

  def create
    # photographer isn't an actual object, but we can search a named Flickr user's photos
    # which is useful, because it finds more than is in the public search
    @photographer = params[:flickr_url]
	@photographer.gsub!('http://www.flickr.com/photos/','')
	@photographer.gsub!(/\/.*/,'')
	puts 'xxxxx' + @photographer
    help.find_photo_by_machinetag(nil, @photographer)
    redirect_to photographers_path
  end
  
  protected
    
    def help
      Helper.instance
    end

    class Helper
      include Singleton
      include PlaquesHelper
    end
    
    class Photographer
      attr_accessor :id
      attr_accessor :photos
      attr_accessor :url
    end

end
