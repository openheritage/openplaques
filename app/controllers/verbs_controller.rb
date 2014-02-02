class VerbsController < ApplicationController

  before_filter :authenticate_admin!, :only => [:destroy]
  before_filter :authenticate_user!, :except => [:index]

  def index
    @verbs = Verb.find(:all, :conditions => "personal_connections_count > 0", :order => :name)
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @verbs }
    end
  end

  def show
    @verb = Verb.find_by_name(params[:id])
    respond_to do |format|
      format.html
      format.xml
      format.json { render :json => @verb }
    end
  end

  def new
    @verb = Verb.new
  end

  def create
    @verb = Verb.new(params[:verb])
    if @verb.save
      redirect_to verb_path(@verb)
    else
      render :new
    end
  end

end
