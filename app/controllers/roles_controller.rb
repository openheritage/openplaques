class RolesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_role, :only => [:show, :edit, :update, :destroy]

  def index
    respond_to do |format|
      format.html { redirect_to(roles_by_index_path) }
      @roles = Role.find(:all, :order => :name)
      format.kml {
        @parent = @roles
        render "colours/index"
      }
      format.yaml
      format.xml
      format.json { render :json => @roles }
    end
  end

  # GET /roles/artist
  # GET /roles/artist.xml
  def show
    if @role == nil # create a dummy role for display purposes
      @role = Role.new
      @role.name = params[:id].downcase
      @role.slug = params[:id].downcase
    end

    @related_roles = @role.related_roles()

    for person in @role.people
      if person # a role record may exist that no longer has a person joined to it
        if (@plaques == nil)
          @plaques = person.plaques
        else
          @plaques = @plaques + person.plaques
        end
      end
    end
    #@centre = find_mean(@plaques)
    @zoom = 7
    respond_to do |format|
      format.html
      format.kml { render "plaques/show" }
      format.yaml
      format.xml
      format.json { render :json => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # POST /roles
  # POST /roles.xml
  def create
    @role = Role.new(params[:role])

    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(role_path(@role.slug)) }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /roles/1
  # PUT /roles/1.xml
  def update
    respond_to do |format|
      if @role.update_attributes(params[:role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(role_path(@role.slug)) }
        format.xml  { head :ok }
      else
        format.html { render "edit" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end

  protected

    def find_role
      @role = Role.find_by_slug(params[:id])
    end

end
