xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  xml.plaque(:id => plaque_url(@plaque), :created_at => @plaque.created_at.xmlschema, :updated_at => @plaque.updated_at.xmlschema){
    xml.inscription {
      xml.raw @plaque.inscription
      xml.linked linked_inscription(@plaque) if linked_inscription(@plaque) != @plaque.inscription
    }
    if @plaque.location or @plaque.geolocated?
      xml.location {
        if @plaque.geolocated?
          xml.geo(:latitude => @plaque.latitude, :longitude => @plaque.longitude)
        end
        if @plaque.location
          xml.tag!("street-address") {
            xml.name @plaque.location.name
          }
          if @plaque.location.area
            xml.locality(:link => area_url(@plaque.location.area)) {
              xml.name @plaque.location.area.name
            }
          end
          if @plaque.location.country
            xml.country(:link => country_url(@plaque.location.country)) {
              xml.name @plaque.location.country.name
            }
          end
        end
      }
    end
    if @plaque.organisation
      xml.organisation(:link => organisation_url(@plaque.organisation)) {
        xml.text! @plaque.organisation.name
      }
    end
    if @plaque.colour
      xml.colour(:uri => colour_url(@plaque.colour)) {
        xml.text! @plaque.colour.name
      }
    end

    if @plaque.erected_at?
      if @plaque.erected_at.day == 1 && @plaque.erected_at.day == 1
        xml.date_erected @plaque.erected_at.year
      else
        xml.date_erected @plaque.erected_at
      end
    end
    @plaque.people.each do |person|
      xml.person(:uri => person_url(person)) {
	    xml.text! person.name
	  }
    end
  }
}
