class SearchController < ApplicationController

  layout "v1"

  def index
	@phrase = params[:phrase]
	if @phrase != nil && @phrase != ""
	    @search_results = get_search_results(@phrase)
		render "results" 
	end
  end

  def results
	@phrase = params[:phrase]
    @search_results = get_search_results(@phrase)
  end
  
  def get_search_results(phrase)
    return Plaque.find(:all, :conditions => ["lower(inscription) LIKE ?", "%" + phrase.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]])
  end
end
