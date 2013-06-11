class OrganisationPlaquesController < ApplicationController

  before_filter :find_organisation, :only => [:show]
  respond_to :json

  def show
    @plaques = @organisation.plaques
    respond_with @plaques do |format|
      format.html { render @plaques }
      format.json { render :json => @plaques.as_json(
        :only => [:id, :latitude, :longitude, :inscription],
        :methods => [:title, :uri, :colour_name]
        ) 
      }
    end
  end

  protected

    def find_organisation
      @organisation = Organisation.find_by_slug!(params[:organisation_id])
    end

end
