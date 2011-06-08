include ActionView::Helpers::TextHelper

class TodoController < ApplicationController

  before_filter :authenticate_user!

  def index
    @photographed_not_coloured_plaques_count = Plaque.photographed_not_coloured.count
    @geo_no_location_plaques_count = Plaque.geo_no_location.count
    @location_no_area_plaques_count = Location.no_area.count
    @plaques_to_add_count = TodoItem.to_add.count
#   @detailed_address_no_geo_count = Plaque.detailed_address_no_geo.count
    @no_connection_count = Plaque.no_connection.count
    @partial_inscription_count = Plaque.partial_inscription.count
    @partial_inscription_photo_count = Plaque.partial_inscription_photo.count
  end

  def destroy
    @todoitem = TodoItem.find(params[:id])
    @todoitem.destroy
    redirect_to todo_path('plaques_to_add')
  end

  def show

    case params[:id]

    when 'colours_from_photos'
      @plaques = Plaque.photographed_not_coloured
      render :colours_from_photos

    when 'locations_from_geolocations'
      @plaques = Plaque.geo_no_location
      render :locations_from_geolocations

    when 'areas_from_locations'
      @locations = Location.no_area
      render :areas_from_locations

    when 'plaques_to_add'
      @plaques_to_add = TodoItem.to_add
      render :plaques_to_add

    when 'no_connection'
      @plaques = Plaque.no_connection
      render :no_connection

    when 'partial_inscription'
      @plaques = Plaque.partial_inscription
      render :partial_inscription

    when 'partial_inscription_photo'
      @plaques = Plaque.partial_inscription_photo
      render :partial_inscription_photo

    when 'detailed_address_no_geo'
      @plaques = Plaque.detailed_address_no_geo
      render :detailed_address_no_geo

    when 'fetch_from_flickr'
      flash[:notice] = pluralize(fetch_todo_items, 'photo') + ' added to the list.'
      redirect_to "/todo/plaques_to_add"

    else
      raise ActiveRecord::RecordNotFound
    end

  end

end
