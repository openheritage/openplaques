class OrganisationsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_organisation, :only => [:edit, :update]

  def index
    if params[:name_starts_with]
      limit = params[:limit] ? params[:limit] : 5
      @organisations = Organisation.name_contains(params[:name_starts_with]).limit(limit).most_plaques_order
    else
      @organisations = Organisation.all(:order => :name)
    end
    respond_to do |format|
      format.html
      format.kml {
        @parent = @organisations
        render "plaques/index"
      }
      format.xml
      format.json { render :json => @organisations }
    end
  end

  def show
    begin
      if (params[:id]=="oxfordshire_blue_plaques_scheme") 
        params[:id] = "oxfordshire_blue_plaques_board"
        redirect_to(organisation_path(params[:id])) and return
      end
      @organisation = Organisation.find_by_slug!(params[:id])
    rescue
      @organisation = Organisation.find(params[:id])
      redirect_to(organisation_path(@organisation.slug), :status => :moved_permanently) and return
    end
    @plaques = @organisation.plaques
    @mean = help.find_mean(@organisation.plaques)
    @zoom = 10
    respond_to do |format|
      format.html
      format.kml { render "plaques/index" }
      format.osm { render "plaques/index" }
      format.xml
      format.json { render :json => @organisation.plaques.as_json }
    end
  end

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new(params[:organisation])

    if @organisation.save
      redirect_to organisation_path(@organisation.slug)
    else
      render :new
    end
  end

  def update
    old_slug = @organisation.slug

    if @organisation.update_attributes(params[:organisation])
      flash[:notice] = 'Updates to organisation saved.'
      redirect_to organisation_path(@organisation.slug)
    else
      @organisation.slug = old_slug
      render "edit"
    end

  end

  protected

    def find_organisation
      @organisation = Organisation.find_by_slug!(params[:id])
    end

    def help
      Helper.instance
    end

    class Helper
      include Singleton
      include PlaquesHelper
    end

end
