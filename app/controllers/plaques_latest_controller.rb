class PlaquesLatestController < ApplicationController

  def show
    @plaques = Plaque.find(:all, :limit => 25, :order => "created_at DESC")
    respond_to do |format|
      format.html 
      format.rss {
        response.headers["Content-Type"] = "application/rss+xml; charset=utf-8"
      }
    end
  end

end
