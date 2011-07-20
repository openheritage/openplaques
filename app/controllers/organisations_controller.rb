class OrganisationsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_organisation, :only => [:edit, :update]

  def index
    if params[:name_starts_with]
      limit = params[:limit] ? params[:limit] : 5
      @organisations = Organisation.name_starts_with(params[:name_starts_with]).limit(limit).most_plaques_order
    else
      @organisations = Organisation.all(:order => :name)
    end
    respond_to do |format|
      format.html
      format.kml {
        @parent = @organisations
        render "colours/index"
      }
      format.yaml
      format.xml { render :xml => @organisations }
      format.json { render :json => @organisations }
    end
  end

  def show
    begin
      @organisation = Organisation.find_by_slug!(params[:id])
    rescue
      @organisation = Organisation.find(params[:id])
      redirect_to(organisation_path(@organisation.slug), :status => :moved_permanently) and return
    end

      @plaques = @organisation.plaques
      @colour_label = @plaques.map {|i| if i.colour.nil? ? "" : i.colour.name }.group_by {|col| col }.max_by(&:size).first || ""
#      @centre = find_mean(@plaques)
      @zoom = 13
      respond_to do |format|
        format.html
        format.kml { render "plaques/show" }
        format.yaml
        format.xml { render :xml => @organisation }
        format.json { render :json => @organisation }
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

end
