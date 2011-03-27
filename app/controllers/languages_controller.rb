class LanguagesController < ApplicationController

  before_filter :authorisation_required, :except => [:index, :show]

  def show
    begin
      @language = Language.find_by_alpha2!(params[:id])
    rescue
      @language = Language.find(params[:id])
      redirect_to(language_url(@language.alpha2), :status => :moved_permanently) and return
    end      

      @plaques = @language.plaques
#      @centre = find_mean(@plaques)
      @zoom = 11
      
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
      redirect_to language_path(@language)
    end
  end
  
  def edit
    @language = Language.find_by_alpha2(params[:id])
  end

  def update
    @language = Language.find_by_alpha2(params[:id])
    
    if @language.update_attributes(params[:language])
      redirect_to language_path(@language)
    else
      render :action => :edit
    end
  end

end
