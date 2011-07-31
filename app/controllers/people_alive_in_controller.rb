class PeopleAliveInController < ApplicationController

  def index
    @counts = Person.count(:born_on)
  end

  def show
    @year = Date.parse(params[:id] + "-01-01")
    @people = Person.find(:all, :conditions => ['born_on <= ? and died_on >= ?', @year, @year], :order => :born_on)
    respond_to do |format|
      format.html
      format.kml { render "plaques/show" }
      format.yaml
      format.xml { render :xml => @people }
      format.json { render :json => @people }
    end
  end

end
