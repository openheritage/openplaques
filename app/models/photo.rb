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

  validates_presence_of :file_url, :plaque, :licence

  attr_accessor :photo_url, :accept_cc_by_licence

  after_initialize :assign_from_photo_url
  before_validation :assign_licence_if_cc_by_accepted

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


end
