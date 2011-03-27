class PlaqueErectedYearsController < ApplicationController

  def index
    @plaque_erected_years = PlaqueErectedYear.find(:all, :order => :name)
  end

  def show
    @plaque_erected_year = PlaqueErectedYear.find_by_name!(params[:id])
  end

end
