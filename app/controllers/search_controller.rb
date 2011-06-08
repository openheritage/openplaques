class SearchController < ApplicationController

  before_filter :set_phrase, :only => [:index, :results]

  def index
    if @phrase != nil && @phrase != ""
        @search_results = get_search_results(@phrase)
      render "results"
    end
  end

  def results
    @search_results = get_search_results(@phrase)
  end

  def get_search_results(phrase)
    return Plaque.find(:all, :conditions => ["lower(inscription) LIKE ?", "%" + phrase.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]])
  end

  protected

    def set_phrase
      @phrase = params[:phrase]
    end

end
