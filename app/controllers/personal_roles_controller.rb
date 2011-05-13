class PersonalRolesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authorisation_required

  def index
    @personal_roles = PersonalRole.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @personal_roles }
    end
  end

  # GET /personal_roles/1
  # GET /personal_roles/1.xml
  def show
    @personal_roles = PersonalRole.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @personal_roles }
    end
  end

  # GET /personal_roles/new
  # GET /personal_roles/new.xml
  def new
    @personal_roles = PersonalRole.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @personal_roles }
    end
  end

  # GET /personal_roles/1/edit
  def edit
    @personal_role = PersonalRole.find(params[:id])
  end

  # POST /personal_roles
  # POST /personal_roles.xml
  def create
    @personal_role = PersonalRole.new
    @role = Role.find(params[:personal_role][:role])
    @personal_role.role = @role
    @person = Person.find(params[:personal_role][:person_id])
    @personal_role.person = @person
    
    if params[:personal_role][:started_at] > ""
      started_at = params[:personal_role][:started_at]
      if started_at =~/\d{4}/
        started_at = started_at + "-01-01"
      end
      started_at = Date.parse(started_at)
      @personal_role.started_at = started_at
    end

   if params[:personal_role][:ended_at] > ""
      ended_at = params[:personal_role][:ended_at]
      if ended_at =~/\d{4}/
        ended_at = ended_at + "-01-01"
      end
      ended_at = Date.parse(ended_at)
      @personal_role.ended_at = ended_at
    end
    
    if @personal_role.save
      flash[:notice] = 'PersonalRole was successfully created.'
      redirect_to(edit_person_path(@personal_role.person))
    else
      @roles = Role.all(:order => :name)
      
      render :template => "people/edit"
    end

  end

  # PUT /personal_roles/1
  # PUT /personal_roles/1.xml
  def update
    @personal_role = PersonalRole.find(params[:id])
    
    started_at = params[:personal_role][:started_at]
    if started_at =~/\d{4}/
      started_at = Date.parse(started_at + "-01-01")
    else
      started_at = Date.parse(started_at)
    end

    ended_at = params[:personal_role][:ended_at]
    if ended_at =~/\d{4}/
      ended_at = Date.parse(ended_at + "-01-01")
    else
      ended_at = Date.parse(ended_at)
    end

    if @personal_role.update_attributes(:started_at => started_at, :ended_at => ended_at)
      redirect_to(edit_person_path(@personal_role.person))
    else
      render :action => :edit
    end

  end

  # DELETE /personal_roles/1
  # DELETE /personal_roles/1.xml
  def destroy
    @personal_role = PersonalRole.find(params[:id])
    @person = @personal_role.person
    @personal_role.destroy

    respond_to do |format|
      format.html { redirect_to(edit_person_url(@person)) }
      format.xml  { head :ok }
    end
  end
end
