class PersonalConnectionsController < ApplicationController

  before_filter :authorisation_required

  def destroy
    @personal_connection = PersonalConnection.find(params[:id])
    @plaque = @personal_connection.plaque
    @personal_connection.destroy
    redirect_to edit_plaque_inscription_path(@plaque)
  end
  
  def edit
    @plaque = Plaque.find(params[:plaque_id])
    @personal_connection = @plaque.personal_connections.find(params[:id])
    @people = Person.all(:order => :name)
    @verbs = Verb.all(:order => :name)
    @locations = Location.all(:order => :name)
  end

  def update
    @plaque = Plaque.find(params[:plaque_id])
    @personal_connection = @plaque.personal_connections.find(params[:id])
    if @personal_connection.update_attributes(params[:personal_connection])
      redirect_to edit_plaque_inscription_path(@plaque.id)
    else
      render :action => :edit
    end

  end
  
  def new
    @plaque = Plaque.find(params[:plaque_id])
    @personal_connection = @plaque.personal_connections.new
    @people = Person.all(:order => :name)
    @verbs = Verb.all(:order => :name)
    @locations = Location.all(:order => :name)    
  end

  def create
    @plaque = Plaque.find(params[:plaque_id])
    @personal_connection = @plaque.personal_connections.new(params[:personal_connection])
    if @personal_connection.save
      redirect_to edit_plaque_inscription_path(@plaque)
    else
      @people = Person.all(:order => :name)
      @verbs = Verb.all(:order => :name)
      @locations = Location.all(:order => :name)    
      render :action => :new      
    end
  end

end
