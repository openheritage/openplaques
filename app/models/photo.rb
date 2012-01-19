# -*- encoding : utf-8 -*-
# This class represents a photograph of a Plaque.
#
# === Attributes
# * +url+ - The primary webpage for the photo - currently always a Flickr photo page.
# * +file_url+ - A link to the actual digital photo file.
# * +photographer+ - The name of the photographer
# * +photographer_url+ - A link to a webpage for the photographer - currently always a Flickr profile page.
# * +shot+ - types of framing technique. One of "extreme close up", "close up", "medium close up", "medium shot", "long shot", "establishing shot"
# * +of_a_plaque+ - whether this is actually a photo of a plaque (and not, for example, mistakenly labelled on Wikimedia as one)
#
# === Associations
# * Licence - The content licence under which the photo is made available.
# * Plaque - the featured in the photo.
require 'curb'

class Photo < ActiveRecord::Base

  belongs_to :plaque, :counter_cache => true
  belongs_to :licence, :counter_cache => true
  belongs_to :user

  validates_presence_of :file_url

  attr_accessor :photo_url, :accept_cc_by_licence

  after_initialize :assign_from_photo_url
  before_validation :assign_licence_if_cc_by_accepted

  scope :detail_order, :order => "shot ASC"
  scope :unassigned, :conditions => ["plaque_id IS NULL"]

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
  
  def shot_order
    if shot
      return shot[0,1]
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
    url && url.starts_with?("http://www.flickr.com")
  end
  
  def wikimedia?
    url.gsub!("http://en.wikipedia.org/","http://commons.wikimedia.org/")
    url && url.starts_with?("http://commons.wikimedia.org")
  end
  
  def wikimedia_filename
    if (wikimedia?)
      return url[url.index('File:')+5..-1]
    end
    return ""
  end
  
  def wikimedia_special
    return "http://commons.wikimedia.org/wiki/Special:FilePath/"+wikimedia_filename+"?width=640"
  end
  
  def flickr_photo_id
    # retrieve from url e.g. http://www.flickr.com/photos/84195101@N00/3412825200/
  end

  def thumbnail_url
    if (file_url.ends_with?("_b.jpg") or file_url.ends_with?("_z.jpg") or file_url.ends_with?("_z.jpg?zz=1") or file_url.ends_with?("_m.jpg"))
	    return file_url.gsub("b.jpg", "s.jpg").gsub("z.jpg?zz=1", "s.jpg").gsub("z.jpg", "s.jpg").gsub("m.jpg", "s.jpg")
	  end
	  if (wikimedia?)
	    return "http://commons.wikimedia.org/wiki/Special:FilePath/"+wikimedia_filename+"?width=75"
    end
  end
  
  # http://commons.wikimedia.org/w/api.php?action=query&iiprop=url|user&prop=imageinfo&format=json&titles=File:George_Dance_plaque.JPG
  def wikimedia_data
    # http://commons.wikimedia.org/wiki/File:George_Dance_plaque.JPG
    # http://commons.wikimedia.org/wiki/File:Abney1.jpg
    if (wikimedia?)   
      url = "http://commons.wikimedia.org/w/api.php?action=query&iiprop=url|user&prop=imageinfo&format=json&titles=File:"+wikimedia_filename
      begin
        ch = Curl::Easy.perform(url) do |curl| 
          curl.headers["User-Agent"] = "openplaques"
          curl.verbose = true
        end
        parsed_json = JSON.parse(ch.body_str)
        parsed_json['query']['pages'].each do |page, pageInfo|
          self.photographer = pageInfo['imageinfo'][0]['user']
        end
        self.photographer_url = "http://commons.wikimedia.org/wiki/User:"+photographer.gsub(' ','_')
      rescue
      end
      self.file_url = wikimedia_special
    end
  end
    
end
