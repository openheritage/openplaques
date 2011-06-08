class PhotoPhotographersController < ApplicationController

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

end
