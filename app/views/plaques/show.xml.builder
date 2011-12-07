xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  xml.plaque(:uri => plaque_url(@plaque), :created_at => @plaque.created_at.xmlschema, :updated_at => @plaque.updated_at.xmlschema){
    xml.title @plaque.title
    xml.inscription {
      xml.raw @plaque.inscription
      xml.linked linked_inscription(@plaque) if linked_inscription(@plaque) != @plaque.inscription
    }
    if @plaque.geolocated?
      xml.geo(:reference_system => "WGS84", :latitude => @plaque.latitude, :longitude => @plaque.longitude)
    end
    if @plaque.location or @plaque.geolocated?
      xml.location {
        if @plaque.location
          xml.address @plaque.location.full_address
          xml.street(:uri => location_url(@plaque.location)) {
            xml.text! @plaque.location.name
          }
          if @plaque.location.area
            xml.locality(:uri => area_url(@plaque.location.area)) {
              xml.text! @plaque.location.area.name
            }
          end
          if @plaque.location.country
            xml.country(:uri => country_url(@plaque.location.country)) {
              xml.text! @plaque.location.country.name
            }
          end
        end
      }
    end
    if @plaque.organisation
      xml.organisation(:uri => organisation_url(@plaque.organisation)) {
        xml.text! @plaque.organisation.name
      }
    end
    if @plaque.colour
      xml.colour @plaque.colour.name
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
