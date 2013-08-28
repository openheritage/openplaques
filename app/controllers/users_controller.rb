class UsersController < ApplicationController

  before_filter :authenticate_admin!

  def index
    @users = User.all
  end

  def show
    @user = User.find_by_username!(params[:id])
  end
  
end
