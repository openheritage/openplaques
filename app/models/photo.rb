# This class represents a photograph of a Plaque.
#
# === Attributes
# * +url+ - The primary webpage for the photo - currently always a Flickr photo page.
# * +file_url+ - A link to the actual digital photo file.
# * +photographer+ - The name of the photographer
# * +photographer_url+ - A link to a webpage for the photographer - currently always a Flickr profile page.
#
# === Associations
# * Licence - The content licence under which the photo is made available.
# * Plaque - the featured in the photo.
class Photo < ActiveRecord::Base

  belongs_to :plaque, :counter_cache => true
  belongs_to :licence, :counter_cache => true

  validates_presence_of :plaque_id, :file_url, :url, :licence_id

end
