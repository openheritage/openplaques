class OrganisationsController < ApplicationController

  before_filter :authorisation_required, :except => [:index, :show]

  def index
    @organisations = Organisation.find(:all, :order => :name)
    respond_to do |format|
      format.html
      format.kml {
        @parent = @organisations
        render :template => "colours/index" 
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
#      @centre = find_mean(@plaques)
      @zoom = 13
      respond_to do |format|
        format.html
        format.kml { render :template => "plaques/show" }
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
      redirect_to @organisation    
    else
      render :action => :new
    end
  end

  def edit
    @organisation = Organisation.find_by_slug(params[:id])
  end

  def update
    @organisation = Organisation.find_by_slug(params[:id])

    if @organisation
      if @organisation.update_attributes(params[:organisation])
        flash[:notice] = 'Organisation was successfully updated.'
        redirect_to organisation_path(@organisation)
      else
        render :action => "edit"
      end
    end
  end

end
