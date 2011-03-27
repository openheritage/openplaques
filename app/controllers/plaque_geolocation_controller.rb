require 'open-uri'
require "rexml/document"
include REXML

class PlaqueGeolocationController < ApplicationController

  before_filter :login_required

  def edit
    @plaque = Plaque.find(params[:plaque_id])
    if (@plaque.location != nil && defined?(YAHOO_GEOCODING_KEY) && @plaque.location.name != ".")
      @yahoo_geo = YahooGeolocation.new
      @yahoo_geo.location = @plaque.location.name 
      if (@plaque.location.area != nil)
	  	  @yahoo_geo.location += ", " + @plaque.location.area.name
      end
      @yahoo_geo.location += ", GB"
      @yahoo_geo = geocode(@yahoo_geo)
    end
  	@geocodes = Array.new
  	unless @plaque.geolocated?
  		@geocodes = geocode_from_flickr
  	end
  end
  
  private

  def geocode_from_flickr
  	geocodes = Array.new
    begin
    	response = open(get_flickr_api_url(params[:plaque_id], true))
    	doc = REXML::Document.new(response.read)	
    	doc.elements.each('//rsp/photos/photo') do |photo|
#    		puts photo.attributes["latitude"]
    		if photo.attributes["latitude"] != nil && photo.attributes["latitude"] != "0"
#    			puts photo.attributes["latitude"] +"."+photo.attributes["longitude"]
    			geocodes.push [photo.attributes["latitude"], photo.attributes["longitude"], photo.attributes["ownername"]]
    		end
    	end
  	rescue
  	end
  	return geocodes
  end
  
  def geocode(yahoo_geo)
    begin
      url = "http://local.yahooapis.com/MapsService/V1/geocode"
    	url += "?appid=" + YAHOO_GEOCODING_KEY
    	address=URI.escape(yahoo_geo.location)
    	puts address
    	url += "&location=" + address
    	result=URI(url).read
    	doc = Document.new result
    	r=doc.elements["/ResultSet/Result"]
    	r.children.each { |c| print c.name, " : ",c.text,"\n"}
    	yahoo_geo.precision = r.attributes["precision"]
     	yahoo_geo.longitude = XPath.first(r,"//Longitude").text
     	yahoo_geo.latitude = XPath.first(r,"//Latitude").text
     	yahoo_geo.address = XPath.first(r,"//Address").text
     	yahoo_geo.city = XPath.first(r,"//City").text
     	yahoo_geo.state = XPath.first(r,"//State").text
     	yahoo_geo.zip = XPath.first(r,"//Zip").text
     	yahoo_geo.country = XPath.first(r,"//Country").text
 	  rescue
 	    yahoo_geo.precision = 'failed'
 	    yahoo_geo.longitude = ''
 	    yahoo_geo.latitude = ''
 	    yahoo_geo.address = ''
 	    yahoo_geo.city = ''
 	    yahoo_geo.state = ''
 	    yahoo_geo.zip = ''
 	    yahoo_geo.country = ''
 	  end
 	  return yahoo_geo
  end
  
end

class YahooGeolocation
  attr_accessor :location
  attr_accessor :precision
  attr_accessor :latitude
  attr_accessor :longitude
  attr_accessor :address
  attr_accessor :city
  attr_accessor :state
  attr_accessor :zip
  attr_accessor :country
end
