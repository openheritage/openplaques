class ApplicationController < ActionController::Base

  module Exceptions
    class UnAuthorised < StandardError; end
  end

  include Exceptions

  layout "v1"

  protect_from_forgery

  rescue_from(ActiveRecord::RecordNotFound) do
    respond_to do |format|
      format.html { render :template => "errors/not_found", :status => 404, :layout => "v1", :formats => [:html] }
      format.json { render :json => {:error => "Not found"}, :status => 404}
      format.xml { render :xml => {:title => "Not found"}, :status => 404}
    end
  end

  rescue_from UnAuthorised, :with => :unauthorised

  def authenticate_admin!
    raise UnAuthorised, "NotAuthorised" unless current_user.try(:is_admin?)
  end

  def unauthorised
    render "public/403.html", :status => :forbidden
  end

  before_filter :ensure_domain

  APP_DOMAIN = 'openplaques.org'

  def ensure_domain
    if Rails.env == "production" && request.env['HTTP_HOST'] != APP_DOMAIN
      # HTTP 301 is a "permanent" redirect
      redirect_to "http://#{APP_DOMAIN}" + request.env['PATH_INFO'], :status => 301
    end
  end

	private
	
	  def set_access_control_headers
      headers['Access-Control-Allow-Origin'] = '*'
    end
    
    def set_cache_header
    	max_age = 1200  # 20 minutes
    	headers['Cache-Control'] = "public, max-age=#{max_age}"
    end

end
