class ApplicationController < ActionController::Base

  module Exceptions
    class UnAuthorised < StandardError; end
  end

  include Exceptions

  protect_from_forgery

  rescue_from UnAuthorised, :with => :unauthorised

  def authenticate_admin!
    raise UnAuthorised, "NotAuthorised" unless current_user.try(:is_admin?)
  end

  def unauthorised
    render "public/403.html", :status => :forbidden
  end


end
