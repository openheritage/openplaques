class AllPlaquesController < ApplicationController

  def show
    respond_to do |format|
      format.html {
        redirect_to plaques_url(:format => :html), :status => :moved_permanently
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
