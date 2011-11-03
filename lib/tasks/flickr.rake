require 'rubygems'
require 'open-uri'
require 'net/http'
require 'uri'
require 'rexml/document'

namespace "photos" do

  desc "Switch Flickr photos to using the largest size"
  task :upsize => [:environment] do

    re = /http:\/\/farm\d.static.flickr.com\/\d+\/.+_m.jpg/

    Photo.find_each do |p|
      if p.file_url =~ re
        p.update_attribute(:file_url, p.file_url.gsub("m.jpg", "b.jpg"))
      end
    end

  end


  desc "Find photos on Flickr"
  task :find => [:environment] do
    key = "86c115028094a06ed5cd19cfe72e8f8b"
    content_type = "1" # Photos only
    machine_tag_key = "openplaques:id"

    flickr_url = "http://api.flickr.com/services/rest/"
    method = "flickr.photos.search"
    license = "1,2,3,4,5,6,7" # All the CC licencses that allow commercial re-use


    url = flickr_url + "?api_key=" + key + "&method=" + method + "&license=" + license + "&content_type=" + content_type + "&machine_tags=" + machine_tag_key +  "=&extras=date_taken,owner_name,license,geo,machine_tags"

    new_photos_count = 0
    response = open(url)
    doc = REXML::Document.new(response.read)
    doc.elements.each('//rsp/photos/photo') do |photo|
      print "."
      $stdout.flush

      @photo = nil

      file_url = "http://farm" + photo.attributes["farm"] + ".static.flickr.com/" + photo.attributes["server"] + "/" + photo.attributes["id"] + "_" + photo.attributes["secret"] + "_b.jpg"
      photo_url = "http://www.flickr.com/photos/" + photo.attributes["owner"] + "/" + photo.attributes["id"] + "/"

      @photo = Photo.find_by_url(photo_url)


      if @photo
      else
        plaque_id = photo.attributes["machine_tags"][/openplaques\:id\=(\d+)/, 1]

        @plaque = Plaque.find(:first, :conditions => {:id => plaque_id})
        if @plaque
          @photo = Photo.new
          @photo.plaque = @plaque
          @photo.file_url = file_url
          @photo.url = photo_url
          @photo.taken_at = photo.attributes["datetaken"]
          @photo.photographer_url = photo_url = "http://www.flickr.com/photos/" + photo.attributes["owner"] + "/"
          @photo.photographer = photo.attributes["ownername"]
          if photo.attributes["license"] == "4"
            @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by/2.0/")
          elsif photo.attributes["license"] == "6"
            @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nd/2.0/")
          elsif photo.attributes["license"] == "3"
            @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nc-nd/2.0/")
          elsif photo.attributes["license"] == "2"
            @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nc/2.0/")
          elsif photo.attributes["license"] == "1"
            @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-nc-sa/2.0/")
          elsif photo.attributes["license"] == "5"
            @photo.licence = Licence.find_by_url("http://creativecommons.org/licenses/by-sa/2.0/")
          elsif photo.attributes["license"] == "7"
            @photo.licence = Licence.find_by_url("http://www.flickr.com/commons/usage/")
          else
            puts "Couldn't find license"
          end
          if @photo.save
            new_photos_count += 1
            #puts "New photo found and saved"
          else
            puts "Error saving photo" + @photo.errors.each_full{|msg| puts msg }
          end

          if photo.attributes["latitude"] != "0" && photo.attributes["longitude"] != "0" && !@plaque.geolocated?
            puts "New geolocation found"
            @plaque.latitude = photo.attributes["latitude"]
            @plaque.longitude = photo.attributes["longitude"]
            @plaque.accuracy = 'flickr'
            if @plaque.save
              puts "New geolocation added to photo"
            else
              puts "Error adding geolocation to photo" + plaque.errors.full_messages.to_s #methods.join(" ")
            end
          end



        else
          #puts "Photo's machine tag doesn't match a plaque."
        end
      end
    end

    puts "\n" + new_photos_count.to_s + " new photos found and saved."

  end
end