require 'open-uri'
require 'net/http'
require 'uri'
require 'rexml/document'

module PlaquesHelper

  def marked_text(text, term)
    text.gsub(/(#{term})/i, '<mark>\1</mark>').html_safe
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

  def title(plaque)
    if plaque.people.size > 4
      people = []
      plaque.people.first(4).each do |person|
        people << person[:name]
      end
        people << pluralize(plaque.people.size - 4, "other")
      people.to_sentence
    elsif plaque.people.size > 0
      return plaque.people.collect(&:name).to_sentence + " plaque"
    else
      return "Plaque #" + plaque.id.to_s
    end
  end

  def kml(plaque, xml)
    if plaque.geolocated?
      xml.Placemark do
        xml.name(title(plaque))
        xml.description do
          xml.cdata!(("<p>" + plaque.inscription + "</p> <p><a href=\"" + plaque_url(plaque) + "\">" + photo_img(plaque) + "</a></p>").html_safe)
        end
        if plaque.latitude && plaque.longitude
          xml.Point do
            xml.coordinates plaque.longitude.to_s + ',' + plaque.latitude.to_s + ",0"
          end
        end
        if plaque.colour && plaque.colour.name =~ /(blue|black|yellow|red|white|green)/
          xml.styleUrl "#plaque-" + plaque.colour.name
        else
          xml.styleUrl "#plaque-blue"
        end
      end
    end
  end

  def machine_tag(plaque)
    return "openplaques:id=" + plaque.id.to_s
  end

  # pass null to search all machinetagged photos on Flickr
  def find_photo_by_machinetag(plaque)
    key = FLICKR_KEY # "86c115028094a06ed5cd19cfe72e8f8b"
    content_type = "1" # Photos only
    machine_tag_key = "openplaques:id=".to_s
    if (plaque)
      machine_tag_key += plaque.id.to_s
    end

    flickr_url = "http://api.flickr.com/services/rest/"
    method = "flickr.photos.search"
    license = "1,2,3,4,5,6,7" # All the CC licencses that allow commercial re-use

    url = flickr_url + "?api_key=" + key + "&method=" + method + "&license=" + license + "&content_type=" + content_type + "&machine_tags=" + machine_tag_key +  "&extras=date_taken,owner_name,license,geo,machine_tags"

    puts url

    new_photos_count = 0
    response = open(url)
    doc = REXML::Document.new(response.read)
    doc.elements.each('//rsp/photos/photo') do |photo|
      print "."
      $stdout.flush

      @photo = nil

      file_url = "http://farm" + photo.attributes["farm"] + ".static.flickr.com/" + photo.attributes["server"] + "/" + photo.attributes["id"] + "_" + photo.attributes["secret"] + "_m.jpg"
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
            @plaque.accuracy = 'flickr'
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
      if plaque.organisation
        s+= "  organisation: " + plaque.organisation.name + "\r\n"
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

  def plaque_list(plaques, context = nil)
    @listy = "".html_safe
    @add = "".html_safe
    @add += content_tag("p", link_to("add one?".html_safe, new_plaque_path)) if current_user && current_user.is_admin?
    @create = "".html_safe
    @create += " ".html_safe + link_to("Create one?".html_safe, new_plaque_path).html_safe if current_user && current_user.is_admin?
    plaques.each do |plaque|
      @loc = map_icon_if_known(plaque)
      @photo = "".html_safe
      if plaque.photographed?
        # icon from http://www.iconarchive.com/show/canon-digital-camera-icons-by-newformula.org/
        camera_icon = image_tag("/images/EOS-300D-32x32.png".html_safe, {:alt => "Photo of plaque".html_safe})
      end

      # RDFa: because plaques have different relationships with the current page.
      # in the context of an organisation page, it is a list of plaques made by that organisation
      # in the context of, say, colour it is a 'has primary colour of' relationship.
      args = case context
        when :organsation then {:rel => "foaf:made".html_safe}
        when :colour then {:rel => "op:primaryColourOf".html_safe}
        else {}
      end

      if plaque.colour
        args = args.merge(:class => plaque.colour.name.downcase)
      end

      @listy << content_tag("tr",
    content_tag("td", link_to("#" + plaque.id.to_s, plaque_path(plaque)), :class => :photo)  +
    content_tag("td", @loc, :class => "geo") +
    content_tag("td", camera_icon, :class => :photo) +
    content_tag("td", new_linked_inscription(plaque)),
          args.merge!(:id => "openplaques:id:".html_safe + plaque.id.to_s))
    end
    @ul = content_tag("table", @listy, :class => :plaque_list)
    out = "".html_safe
    if @plaques.size > 0
      out << content_tag("p", pluralize(@plaques.size.to_s, "plaque"))
      out << @ul
      out << @add
    else
      out << content_tag("p", "No plaques yet.".html_safe + @create.html_safe)
    end

  end

  def erected_information(plaque)
    if plaque.erected_at? or plaque.organisation
      info = link_to(h(plaque.organisation.name), plaque.organisation) if plaque.organisation
      if plaque.erected_at?
        info += " ".html_safe
        if plaque.erected_at.day == 1 && plaque.erected_at.month == 1
          info += "in ".html_safe
        else
          info += "on ".html_safe + plaque.erected_at.strftime('%d %B') + " "
        end
        info += link_to(plaque.erected_at.year.to_s, plaque_erected_year_path(plaque.erected_at.year.to_s))
      end
      info += "."
      return content_tag("p", info)
    else
      return content_tag("p", "Erected by: ".html_safe + content_tag("span", "unknown".html_safe, :class => :unknown) + ".")
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

end
