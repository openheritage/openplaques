class AllAreasController < ApplicationController

  respond_to :json

  def show
    if params[:term]
      @areas = Area.all(:conditions => ["lower(areas.name) LIKE ?", params[:term].downcase + "%"], :limit => 10, :order => "areas.locations_count DESC", :include => :country)
    elsif params[:id]
      @areas = Area.all(:conditions => ["lower(areas.name) LIKE ?", params[:id].downcase + "%"], :limit => 10, :order => "areas.locations_count DESC", :include => :country)
    else
      @areas = Area.all
    end
    respond_with @areas.as_json()
  end
  # [{"label": "test", "value": "1"}]

end
