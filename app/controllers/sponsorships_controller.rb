class SponsorshipsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy

  before_filter :find_plaque, :only => [:edit, :update, :new]
  before_filter :find_sponsorship, :only => [:edit, :destroy]

  def destroy
    @sponsorship.destroy
    redirect_to :back
  end

  def edit
    @organisations = Organisation.all(:order => :name)
  end

  def update
    @sponsorship = @plaque.sponsorships.find(params[:id])
    if @sponsorship.update_attributes(params[:sponsorship])
      redirect_to edit_plaque_path(@plaque.id)
    else
      render :edit
    end
  end

  def new
    @sponsorship = @plaque.sponsorships.new
    @organisations = Organisation.all(:order => :name)
  end

  def create
    @plaque = Plaque.find(params[:sponsorship][:plaque_id])
    @sponsorship = @plaque.sponsorships.new(params[:sponsorship])
    if @sponsorship.save
      redirect_to :back
    else
      @organisations = Organisation.all(:order => :name)
      render :new
    end
  end

  protected

    def find_plaque
      if params[:plaque_id]
        @plaque = Plaque.find(params[:plaque_id])
      end
    end

    def find_sponsorship
      @sponsorship = Sponsorship.find(params[:id])
      @plaque = @sponsorship.plaque
    end

end
