class PagesController < ApplicationController

  before_filter :authenticate_admin!, :only => :destroy
  before_filter :authenticate_user!, :except => [:show]

	def about
		@organisations_count = Organisation.count
	end

  def show
    @page = Page.find_by_slug(params[:id])
    raise ActiveRecord::RecordNotFound unless @page

  end
  
  def index
    @pages = Page.all(:order => :slug)
  end
  
  def new
    @page = Page.new
  end

  def create
    @page = Page.new(params[:page])
    
    if @page.save
      redirect_to pages_path
    end  
    
  end
  
  def update
    @page = Page.find_by_slug(params[:id])
    raise ActiveRecord::RecordNotFound unless @page
    
    if @page.update_attributes(params[:page])
      redirect_to :action => :show, :id => @page.slug
    end
    
  end
  
  def edit
    @page = Page.find_by_slug(params[:id])
    raise ActiveRecord::RecordNotFound unless @page
  end

end