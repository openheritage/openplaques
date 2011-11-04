# -*- encoding : utf-8 -*-
# This class represents a photograph of a Plaque.
#
# === Attributes
# * +url+ - The primary webpage for the photo - currently always a Flickr photo page.
# * +file_url+ - A link to the actual digital photo file.
# * +photographer+ - The name of the photographer
# * +photographer_url+ - A link to a webpage for the photographer - currently always a Flickr profile page.
# * +shot+ - types of framing technique. One of "extreme close up", "close up", "medium close up", "medium shot", "long shot", "establishing shot"
#
# === Associations
# * Licence - The content licence under which the photo is made available.
# * Plaque - the featured in the photo.
class Photo < ActiveRecord::Base

  belongs_to :plaque, :counter_cache => true
  belongs_to :licence, :counter_cache => true
  belongs_to :user

  validates_presence_of :file_url, :plaque, :licence

  attr_accessor :photo_url, :accept_cc_by_licence

  after_initialize :assign_from_photo_url
  before_validation :assign_licence_if_cc_by_accepted

  scope :detail_order, :order => "shot ASC"

  def assign_from_photo_url
    if @photo_url
      if @photo_url =~ /http\:\/\/www\.flickr\.com\/photos\/.+\/\d+\//
        self.url = @photo_url
      else
        self.file_url = @photo_url
      end
    end
  end

  def assign_licence_if_cc_by_accepted
    if @accept_cc_by_licence && @licence_id.blank?
      self.licence = Licence.find_or_create_by_name_and_url("Attribution License", "http://creativecommons.org/licenses/by/3.0/")
      self.photographer = self.plaque.user.name
    end
  end

  def title
    "photo № #{id}"
  end
  
  def shot_name
    if shot
      return shot[3,shot.length]
    end
  end

  def self.shots
    ["1 - extreme close up", "2 - close up", "3 - medium close up", "4 - medium shot", "5 - long shot", "6 - establishing shot"]
  end
  
  def ping?
    begin # check header response
      case Net::HTTP.get_response(URI.parse(file_url))
        when Net::HTTPSuccess then return true
        else return false
      end
    rescue # Recover optimistically on DNS failures..
	  return true
    end 
  end
  
  def flickr?
    photo_url && photo_url.starts_with?("http://www.flickr.com")
  end
  
  def flickr_photo_id
    # retrieve from photo_url e.g. http://www.flickr.com/photos/84195101@N00/3412825200/
  end
    
end
