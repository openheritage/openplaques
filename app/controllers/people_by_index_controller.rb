class PeopleByIndexController < ApplicationController

  def index
  end

  def show
    @index = params[:id]

    if @index =~ /^[A-Z]$/
      redirect_to people_by_index_path(@index.downcase), :status => :moved_permanently
    elsif @index =~ /^[a-z]$/
      @people = Person.find(:all, :conditions => {:surname_starts_with => @index, :personal_connections_count => 1..999999})  # Can't figure out how to do a NOT "0" expression.
      @people.sort! { |a,b| a.surname.downcase <=> b.surname.downcase }
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end
