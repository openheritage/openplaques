class PicksController < ApplicationController

  before_filter :find_pick, :only => [:edit, :update, :show, :destroy]

  def index
    @picks = Pick.all
  end

  def new
    @picks = Pick.new
  end

  def create
    @pick = Pick.new
    @plaque = Plaque.find(params[:pick][:plaque_id])
    @pick.plaque = @plaque
    @pick.description = params[:pick][:description].to_s
    @pick.save
    redirect_to picks_path()
  end

  def destroy
    @pick.destroy
    redirect_to picks_path()
  end
  
  def promote
    @pick.last_featured = DateTime.now
    @pick.save
#    redirect_to picks_path()
  end

  protected

    def find_pick
      @pick = Pick.find(params[:id])
    end

end
