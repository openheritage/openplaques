class PeopleByIndexController < ApplicationController

  layout "v1"

  def index
  end

  def show
    @index = params[:id]

    if @index =~ /^[A-Z]$/
      redirect_to people_by_index_path(@index.downcase), :status => :moved_permanently
    elsif @index =~ /^[a-z]$/
#      @people = Person.find(:all, :conditions => {:index => @index, :personal_connections_count => 1..999999}, :order => :name)  # Can't figure out how to do a NOT "0" expression.
      @people = Person.find(:all, :conditions => {:surname_starts_with => @index, :personal_connections_count => 1..999999}, :order => :name)  # Can't figure out how to do a NOT "0" expression.
    else
      raise ActiveRecord::RecordNotFound
    end
  end

end
