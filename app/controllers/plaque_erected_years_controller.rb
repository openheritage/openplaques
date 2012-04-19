class PlaqueErectedYearsController < ApplicationController

  respond_to :html, :json

  def index
    @plaque_erected_years = PlaqueErectedYear.find(:all, :order => :name)
    respond_with @plaque_erected_years
  end

  def show
    @plaque_erected_year = PlaqueErectedYear.find_by_name!(params[:id])
    respond_with @plaque_erected_year
  end

end
