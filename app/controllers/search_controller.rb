class SearchController < ApplicationController

  before_filter :set_phrase, :only => [:index, :results]

  def index
    if @phrase != nil && @phrase != ""
      if @street != nil && @street !=""
        @search_results = Plaque.find(:all, :joins => :location, :conditions => ["lower(inscription) LIKE ? and lower(locations.name) LIKE ?", "%" + @phrase.downcase + "%", "%" + @street.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]])
      else
        @search_results = Person.find(:all, :conditions => ["lower(name) LIKE ?", "%" + @phrase.downcase + "%"])
        @search_results += Plaque.find(:all, :conditions => ["lower(inscription) LIKE ?", "%" + @phrase.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]]).sort!{|t1,t2|t1.to_s <=> t2.to_s}
      end
      render "results"
    elsif  @street != nil && @street !=""
      @search_results = Plaque.find(:all, :joins => :location, :conditions => ["lower(locations.name) LIKE ?", "%" + @street.downcase + "%"], :include => [[:personal_connections => [:person]], [:location => [:area => :country]]])      
      @phrase = ""
      render "results"
    end
  end

  def get_search_results(phrase)
  end

  protected

    def set_phrase
      @phrase = params[:phrase]
      @street = params[:street]
    end

end
