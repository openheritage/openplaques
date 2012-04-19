require 'open-uri'
require 'net/http'
require 'uri'
require 'rexml/document'

module PlaquesHelper

  def marked_text(text, term)
    text.to_s.gsub(/(#{term})/i, '<mark>\1</mark>').html_safe
  end

  def search_snippet(text, search_term)
    regex = /#{search_term}/i
    if text =~ regex
      text = " " + text + " "  #HACK: This is so there's a space before the first word.
      indexes = []
      first_index = text.index(regex)
      indexes << first_index
      second_index = text.index(regex, (first_index + search_term.length + 50))
      indexes << second_index if second_index
      snippet = ""
      indexes.each do |i|
        i = i - 80
        i = 0 if i < 0
        s = text[i, 160]
        first_space = (s.index(/\s/) + 1)
        last_space = (s.rindex(/\s/) - 1)
        snippet += "..." if i > 0
        snippet += (s[first_space..last_space])
        snippet += "..." if last_space + 2 < text.length
      end
      snippet
    else
      return text
    end
  end

  def kml(plaque, xml)
    if plaque.geolocated?
      xml.Placemark do
        xml.name(plaque.title)
        xml.description do
          xml.cdata!(("<p>" + plaque.inscription + "</p> <p><a href=\"" + plaque_url(plaque) + "\">" + thumbnail_img(plaque) + "</a></p>").html_safe)
        end
        if plaque.latitude && plaque.longitude
          xml.Point do
            xml.coordinates plaque.longitude.to_s + ',' + plaque.latitude.to_s + ",0"
          end
        end
        if plaque.colour && plaque.colour.slug =~ /(blue|black|yellow|red|white|green)/
          xml.styleUrl "#plaque-" + plaque.colour.slug
        else
          xml.styleUrl "#plaque-blue"
        end
      end
    end
  end

  # pass null to search all machinetagged photos on Flickr
  def find_photo_by_machinetag(plaque, flickr_user_id)
#    key = FLICKR_KEY # "86c115028094a06ed5cd19cfe72e8f8b"
    key = "86c115028094a06ed5cd19cfe72e8f8b"
    content_type = "1" # Photos only
    machine_tag_key = "openplaques:id=".to_s
    if (plaque)
      machine_tag_key += plaque.id.to_s
    end

    flickr_url = "http://api.flickr.com/services/rest/"
    method = "flickr.photos.search"
    license = "1,2,3,4,5,6,7" # All the CC licencses that allow commercial re-use

    url = flickr_url + "?api_key=" + key + "&method=" + method + "&license=" + license + "&content_type=" + content_type + "&machine_tags=" + machine_tag_key +  "&extras=date_taken,owner_name,license,geo,machine_tags"

    if (flickr_user_id)
      url += "&user_id=" + flickr_user_id
    end
    puts url

    new_photos_count = 0
    response = open(url)
    doc = REXML::Document.new(response.read)
    doc.elements.each('//rsp/photos/photo') do |photo|
      print "."
      $stdout.flush

      @photo = nil

      file_url = "http://farm" + photo.attributes["farm"] + ".staticflickr.com/" + photo.attributes["server"] + "/" + photo.attributes["id"] + "_" + photo.attributes["secret"] + "_z.jpg"
      photo_url = "http://www.flickr.com/photos/" + photo.attributes["owner"] + "/" + photo.attributes["id"] + "/"

      @photo = Photo.find_by_url(photo_url)

      if @photo
      else
        plaque_id = photo.attributes["machine_tags"][/openplaques\:id\=(\d+)/, 1]

        puts photo.attributes["title"]

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
            puts "New photo found and saved"
          else
#            puts "Error saving photo" + @photo.errors.each_full{|msg| puts msg }
          end

          if photo.attributes["latitude"] != "0" && photo.attributes["longitude"] != "0" && !@plaque.geolocated?
            puts "New geolocation found"
            @plaque.latitude = photo.attributes["latitude"]
            @plaque.longitude = photo.attributes["longitude"]
            if @plaque.save
              puts "New geolocation added to photo"
            else
              puts "Error adding geolocation to photo" + plaque.errors.full_messages.to_s #methods.join(" ")
            end
          end
        else
          puts "Photo's machine tag doesn't match a plaque."
        end
      end
    end
  end

  def yaml(plaques)
#    plaques.to_yaml
    s = ""
    plaques.each do |plaque|
      s += "plaque" + plaque.id.to_s + ":\r\n"
      s += "  inscription: " + h(plaque.inscription).gsub(/\r\n/,"") + "\r\n"
      if plaque.location
        s+= "  location: " + plaque.location.name + "\r\n"
      end
      if plaque.erected_at
        s+= "  erected_at: " + plaque.erected_at_string + "\r\n"
      end
      if !plaque.organisations.empty?
        s+= "  organisation: " + plaque.organisations.first.name + "\r\n"
      end
      unless plaque.notes.blank?
        s+= "  notes: " + h(plaque.notes).gsub(/\r\n/," ") + "\r\n"
      end
      if plaque.colour
        s+= "  colour: " + plaque.colour.name + "\r\n"
      end
      s+= "\r\n"
    end
    return s
  end

  def poi(plaque)
    if plaque.geolocated? && plaque.people.size() > 0
    plaque.longitude.to_s + ', ' + plaque.latitude.to_s + ", \"" + plaque.people.collect(&:name).to_sentence + "\"" + "\r\n"
    end
  end

  def personal_connection_path(pc)
    url_for(:controller => "PersonalConnections", :action => :show, :id => pc.id, :plaque_id => pc.plaque_id)
  end

  def personal_connections_path(plaque)
    url_for(:controller => "PersonalConnections", :action => :index, :plaque_id => plaque.id)
  end

  def edit_personal_connection_path(pc)
    url_for(:controller => "PersonalConnections", :action => :edit, :id => pc.id, :plaque_id => pc.plaque_id)
  end

  def new_personal_connection_path(plaque)
    url_for(:controller => "PersonalConnections", :action => :new, :plaque_id => plaque.id)
  end

  def list(things, context = nil, extras = nil)
    # things.sort!{|t1,t2|t1.to_s <=> t2.to_s}
    @listy = "".html_safe
    things.each do |thing|
      # RDFa: because plaques have different relationships with the current page.
      # in the context of an organisation page, it is a list of plaques made by that organisation
      # in the context of, say, colour it is a 'has primary colour of' relationship.
      args = case context
        when :organisation then {:rel => "foaf:made".html_safe}
        when :colour then {:rel => "op:primaryColourOf".html_safe}
        else {}
      end

      begin
        args = args.merge(:class => thing.colour.name.downcase)
      rescue
      end

      begin
        extras = case context
          when :no_connection then content_tag("td", button_to("Add connection", new_plaque_connection_path(thing), :method => :get, :class => :button))
          when :partial_inscription then content_tag("td", button_to("Edit inscription", edit_plaque_inscription_path(thing), :method => :get, :class => :button))
          when :colours_from_photos then content_tag("td", button_to("Edit colour", edit_plaque_colour_path(thing), :method => :get, :class => :button))
          when :detailed_address_no_geo then content_tag("td", button_to("Edit geolocation", edit_plaque_geolocation_path(thing), :method => :get, :class => :button))
        end
        @listy << content_tag("tr",
          content_tag("td", link_to(thumbnail_img(thing), plaque_path(thing)), :class => :photo)  +
          content_tag("td", link_to(thing.to_s, plaque_path(thing))) +
          content_tag("td", new_linked_inscription(thing)) +
          extras,
          args.merge!(:id => thing.machine_tag.html_safe)
        )
      rescue
        # maybe it is a person
        begin
          @listy << content_tag("tr",
            content_tag("td", link_to(thumbnail_img(thing), person_path(thing)), :class => :photo)  +
            content_tag("td", link_to(thing.to_s, person_path(thing))) +
            content_tag("td", "")
          )
        rescue
          @listy << content_tag("tr",
            content_tag("td", thumbnail_img(thing), :class => :photo)  +
            content_tag("td", thing.to_s) +
            content_tag("td", "** not sure what this object is (or something threw an error) **")
          )
        end
      end
    end
    @ul = content_tag("table", @listy, :class => :plaque_list)
    out = "".html_safe
    if things.size > 0
      out << content_tag("p", pluralize(things.size.to_s, "results"))
      out << @ul
    else
      out << content_tag("p", "Nothing found.".html_safe)
    end
  end

  def plaque_organisation_links(plaque)

    plaque_organisations = plaque.organisations

    if plaque_organisations.size > 0
      links = plaque.organisations.collect do |organisation|
        link_to(h(organisation.name), organisation)
      end
      links.to_sentence
    else
      "an unknown organisation".html_safe
    end
  end

  def erected_date(plaque)
    if plaque.erected_at?
      if plaque.erected_at.day == 1 && plaque.erected_at.month == 1
        "in ".html_safe + plaque.erected_at.year.to_s
      else
        "on ".html_safe + plaque.erected_at.strftime('%d %B %Y')
      end
    else
      "sometime in the past"
    end
  end

  def erected_information(plaque)
    info = "".html_safe
    if plaque.erected_at? or !plaque.organisations.empty?
      info += "by ".html_safe if !plaque.organisations.empty?
      org_list = []
      plaque.organisations.each do |organisation|
        org_list << link_to(h(organisation.name), organisation)
      end
      info += org_list.to_sentence.html_safe
      if plaque.erected_at?
        info += " ".html_safe
        if plaque.erected_at.day == 1 && plaque.erected_at.month == 1
          info += "in ".html_safe
        else
          info += "on ".html_safe + plaque.erected_at.strftime('%d %B') + " "
        end
        info += plaque.erected_at.year.to_s
      end
      return content_tag("p", info)
    else
      return content_tag("p", "by ".html_safe + content_tag("span", "unknown".html_safe, :class => :unknown))
    end
  end

    def linked_inscription(plaque)
      if plaque.personal_connections.size > 0
        s = []
        locations = []
        plaque.personal_connections.each do |pc|
          locations << pc.location
        end

        locations.uniq!
        locations.each do |location|
          people = []
          sentence = []
          plaque.personal_connections.each do |pc|
            if pc.location == location
              people << pc.person
            end
          end
          people.uniq!

          people.each do |person|
            sub_sentence = []
            verbs = []
            plaque.personal_connections.each do |pc|
              if pc.person == person && pc.location == location
                sub_sub_sentence = link_to(pc.verb.name, pc.verb)
  #              sub_sub_sentence += " from "+ pc.started_at.year.to_s + " to " + pc.ended_at.year.to_s if pc.started_at && pc.ended_at
                verbs << sub_sub_sentence
              end
            end
            ss = content_tag("span",dated_roled_person(person), {:class => "vcard"}) + ", ".html_safe + verbs.to_sentence.html_safe + " "
            if location == plaque.location
              ss += link_to("here".html_safe, location)
            elsif location == nil
              # huh? maybe it only has an area?
            else
              ss += link_to(location.name, location)
            end

            plaque.personal_connections.each do |pc|
              if pc.person == person && pc.location == location
                ss += " from ".html_safe + pc.started_at.year.to_s + " to ".html_safe + pc.ended_at.year.to_s if pc.started_at? && pc.ended_at?
              end
            end

            sub_sentence << ss
            sentence << sub_sentence
          end


          s << sentence.to_sentence
        end

        return (s.to_sentence + ".".html_safe).html_safe
      else
        return plaque.inscription
      end
    end

  def geolocation_if_known(plaque)
    if plaque.geolocated?
      geo_microformat(plaque)
    else
      unknown()
    end
  end

  def map_icon_if_known(plaque)
    if plaque.geolocated?
      geo_map_icon_link(plaque)
    else
      ""
    end
  end

  def google_map_if_known(content, plaque)
    if plaque.geolocated?
      link_to_google_map(content, plaque.latitude, plaque.longitude)
    else
      unknown()
    end
  end

  def google_streetview_if_known(content, plaque)
    if plaque.geolocated?
      link_to_google_streetview(content, plaque.latitude, plaque.longitude)
    else
      unknown()
    end
  end

  def google_earth_if_known(content, plaque)
    if plaque.geolocated?
      link_to_google_earth(content, plaque.id)
    else
      unknown()
    end
  end

  # Generates a link to Open Street Map using latitude ang longitude.
  def link_to_osm(content, latitude, longitude, marker = true)
   link_to(content, "http://www.openstreetmap.org/?lat=" + latitude.to_s + "&amp;lon=" + longitude.to_s + "&amp;zoom=17&amp;mlat=" + latitude.to_s + "&amp;mlon=" + longitude.to_s)
  end

  # Generates a link to Google Maps using latitude ang longitude.
  def link_to_google_map(content, latitude, longitude)
   link_to(content, "http://maps.google.co.uk?q=" + latitude.to_s + "," + longitude.to_s)
  end

  # Generates a link to Google Street View using latitude ang longitude.
  def link_to_google_streetview(content, latitude, longitude)
   link_to(content, "http://maps.google.co.uk/?q=" + latitude.to_s + "," + longitude.to_s + "&layer=c&cbll=" + latitude.to_s + "," + longitude.to_s + "&cbp=12,0,,0,5")
  end

  # Generates a link to Google Earth using id for kml.
  def link_to_google_earth(content, id)
   link_to(content, "http://maps.google.co.uk?t=f&q=http://openplaques.org/plaques/" + id.to_s + ".kml")
  end

  def osm_iframe(latitude, longitude, bboffset = 0.001, height = 200, width = 300, marker = true)
    bb = (longitude - bboffset).to_s + "," + (latitude - bboffset).to_s + "," + (longitude + bboffset).to_s + "," + (latitude + bboffset).to_s

    osm_embed_src = "http://www.openstreetmap.org/export/embed.html?bbox=" + bb + "&amp;marker=" + latitude.to_s + "," + longitude.to_s + "&amp;layer=mapnik"
    return content_tag("iframe","",{:height => height, :width => width, :scrolling => "no", :frameborder => "no", :marginheight => "0", :marginwidth => "0", :src => osm_embed_src, :class => "osm"})
  end

  def geo_microformat(plaque, container = "span")
    if !plaque.geolocated?
      return ""
    end
    @lat = content_tag("span", plaque.latitude, {:class => "latitude", :property => "geo:lat", :about => "#plaque_location"})
    @lon = content_tag("span", plaque.longitude, {:class => "longitude", :property => "geo:long", :about => "#plaque_location"})
    content_tag(container, link_to_osm(@lat + ", " + @lon, plaque.latitude, plaque.longitude), {:class => "geo", :typeof => "geo:Point", :about => "#plaque_location"})
  end

  def geo_map_icon_link(plaque)
    if !plaque.geolocated?
    return "";
    end
    @alt = plaque.latitude.to_s + ", " + plaque.longitude.to_s
    @image = image_tag("map_icon.png", {:alt => @alt})
    link_to_osm(@image, plaque.latitude, plaque.longitude )
  end

  def plaque_icon(plaque)
  if plaque.colour && plaque.colour.slug =~ /(blue|black|yellow|red|white|green)/
      image_tag("icon-" + plaque.colour.slug + ".png", :size => "16x16")
    else
      image_tag("icon-blue.png", :size => "16x16")
    end
  end

  def new_linked_inscription(plaque)
    inscription = plaque.inscription
    connections = plaque.personal_connections.all(:select => "personal_connections.person_id", :group => "personal_connections.person_id")
    if connections.size > 0
      connections.each do |connection|
        if inscription.index(connection.person.name) != nil
          inscription = inscription.gsub(connection.person.name, link_to(connection.person.name, person_path(connection.person))).html_safe
        elsif (connection.person.name.rindex(" "))
          search_for = connection.person.name[0,connection.person.name.rindex(" ")]
          inscription = inscription.gsub(search_for, link_to(search_for, person_path(connection.person))).html_safe if search_for
        end
      end
    end
  if plaque.inscription_is_stub
    inscription += " [full inscription unknown]"
  end
    return inscription
  end

  # given a set of plaques, or a thing that has plaques (like an organisation) tell me what the mean point is
  def find_mean(things)
    begin
      @centre = Point.new
      @centre.latitude = 51.475 # Greenwich Meridian
      @centre.longitude = 0
      begin
        @lat = 0
        @lon = 0
        @count = 0
        things.each do |thing|
          if thing.geolocated?
            @lat += thing.latitude
            @lon += thing.longitude
            @count = @count + 1
          end
        end
        @centre.latitude = @lat / @count
        @centre.longitude = @lon / @count
#        puts ("****** lat= " + @centre.latitude.to_s + ",lon= " + @centre.longitude.to_s + " from " + thing.size.to_s + " plaques, " + @count.to_s + " are geolocated")
        return @centre
      rescue
        # oh, maybe it's a thing that has plaques
        return find_mean(thing.plaques)
      end
    rescue
      # something went wrong, failing gracefully
      return @centre
    end
  end

  class Point
    attr_accessor :precision
    attr_accessor :latitude
    attr_accessor :longitude
    attr_accessor :zoom
  end

end
