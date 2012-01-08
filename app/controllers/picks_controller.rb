class PicksController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_pick, :only => [:edit, :update, :show, :destroy]

  def index
    @picks = Pick.all
  end

  def new
    @picks = Pick.new
  end

  def create
    @pick = Pick.new(params[:pick])
    @plaque = Plaque.find(params[:pick][:plaque_id])
    @pick.plaque = @plaque
    @pick.save
    redirect_to picks_path
  end

  def destroy
    @pick.destroy
    redirect_to picks_path
  end

  def promote
    @pick.last_featured = DateTime.now
    @pick.save
  end

  def update
    if @pick.update_attributes(params[:pick])
      redirect_to pick_path(@pick)
    else
      render :edit
    end
  end

  protected

    def find_pick
      @pick = Pick.find(params[:id])
    end

end
