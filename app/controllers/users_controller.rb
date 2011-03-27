class UsersController < ApplicationController
  
  def index
    if params[:all]
      @users = User.all
    else
      @users = User.find(:all, :conditions => {:is_verified => true})
    end
  end
  
  def show
    @user = User.find_by_username!(params[:id])
  end
end
