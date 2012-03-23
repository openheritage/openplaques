class VerbsController < ApplicationController

  before_filter :authenticate_admin!, :only => [:destroy]
  before_filter :authenticate_user!, :except => [:index, :show]

  def index
    @verbs = Verb.find(:all, :conditions => "personal_connections_count > 0", :order => :name)
    respond_to do |format|
      format.html
      format.xml # { render :xml => @verbs }
      format.json { render :json => @verbs }
    end
  end

  def show
    begin
      @verb = Verb.find_by_name!(params[:id])
    rescue
      @verb = Verb.find(params[:id])
      redirect_to verb_path(@verb) and return
    end
    respond_to do |format|
      format.html
      format.xml # { render :xml => @verb }
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
