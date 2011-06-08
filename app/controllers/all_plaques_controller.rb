class AllPlaquesController < ApplicationController

  def show
    respond_to do |format|
      format.html {
        @plaques = Plaque.find(:all, :order => :id, :include => [:organisation, {:location => :area}, :colour])
      }
      format.yaml {
        redirect_to plaques_url(:format => :yaml), :status => :moved_permanently
       }
      format.kml {
        redirect_to plaques_url(:format => :kml), :status => :moved_permanently
      }
      format.json {
        redirect_to plaques_url(:format => :json), :status => :moved_permanently
      }
      format.xml {
        redirect_to plaques_url(:format => :xml), :status => :moved_permanently
      }

    end
  end

end
