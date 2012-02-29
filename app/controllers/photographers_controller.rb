class PhotographersController < ApplicationController

  def index
    @photographers = Photo.count(:photographer, :group => 'photographer')
  end

  def show
    @photographer = params[:id]
    @photos = Photo.find(:all, :conditions => {:photographer => @photographer})
    if @photos.length == 0
      @photographer = params[:id].gsub(/\_/,'.')
      @photos = Photo.find(:all, :conditions => {:photographer => @photographer})
    end
  end

  def new
  end

  def create
    @photographer = params[:flickr_url]
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

end
