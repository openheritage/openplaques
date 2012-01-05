class PersonalConnectionsController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy

  before_filter :find_plaque, :only => [:edit, :update, :new, :create]
  before_filter :find_personal_connection, :only => [:edit, :destroy]

  def destroy
    @personal_connection.destroy
    redirect_to :back
  end

  def edit
    @people = Person.all(:order => :name)
    @verbs = Verb.all(:order => :name)
    @locations = Location.all(:order => :name)
  end

  def update
    @personal_connection = @plaque.personal_connections.find(params[:id])
    if @personal_connection.update_attributes(params[:personal_connection])
      redirect_to edit_plaque_path(@plaque.id)
    else
      render :edit
    end
  end

  def new
    @personal_connection = @plaque.personal_connections.new
    @people = Person.all(:order => :name)
    @verbs = Verb.all(:order => :name)
  end

  def create
    @personal_connection = @plaque.personal_connections.new(params[:personal_connection])
    if @personal_connection.save
      redirect_to :back
    else
      @people = Person.all(:order => :name)
      @verbs = Verb.all(:order => :name)
      @locations = Location.all(:order => :name)
      render :new
    end
  end


  protected

    def find_plaque
      @plaque = Plaque.find(params[:plaque_id])
    end

    def find_personal_connection
      @personal_connection = PersonalConnection.find(params[:id])
    end

end
