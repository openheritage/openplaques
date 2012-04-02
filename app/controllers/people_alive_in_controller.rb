class PeopleAliveInController < ApplicationController

  def index
    @counts = Person.count(:born_on)
  end

  def show
    @year = Date.parse(params[:id] + "-01-01")
    @people = Person.find(:all, :conditions => ['born_on between ? and ? and died_on between ? and ?', @year - 120.years, @year, @year, @year + 120.years], :order => [:born_on, :surname_starts_with, :name])
    respond_to do |format|
      format.html
      format.kml { render "plaques/show" }
      format.yaml
      format.xml { render :xml => @people }
      format.json { render :json => @people }
    end
  end

end
