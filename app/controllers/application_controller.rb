class ApplicationController < ActionController::Base

  module Exceptions
    class UnAuthorised < StandardError; end
  end

  include Exceptions

  layout "v1"

  protect_from_forgery

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

end
