class LanguagesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:index, :show]

  before_filter :find_language, :only => [:edit, :update]

  def show
    begin
      @language = Language.find_by_alpha2!(params[:id])
    rescue
      @language = Language.find(params[:id])
      redirect_to(language_url(@language.alpha2), :status => :moved_permanently) and return
    end
  end

  def index
    @languages = Language.all
  end

  def new
    @language = Language.new
  end

  def create
    @language = Language.new(params[:language])

    if @language.save
      redirect_to language_path(@language.alpha2)
    end
  end

  def update
    if @language.update_attributes(params[:language])
      redirect_to language_path(@language)
    else
      render :edit
    end
  end

  protected

    def find_language
      @language = Language.find_by_alpha2!(params[:id])
    end

end
