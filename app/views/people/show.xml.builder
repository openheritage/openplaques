xml.instruct! :xml, :version=>"1.0"
xml.openplaques(:uri => person_url(@person)){
  xml.person(:uri => person_url(@person), :updated_at => @person.updated_at.xmlschema) {
    xml.name @person.name
    xml.surname @person.surname
    xml.born {
      xml.in { xml.text! @person.born_in.to_s } unless @person.born_in.blank?
      xml.at(:uri => location_url(@person.born_at.id)) {
	      xml.address @person.born_at.full_address
		    xml.geo(:reference_system => "WGS84", :latitude => @person.birth_connection.plaque.latitude, :longitude => @person.birth_connection.plaque.longitude) unless !@person.birth_connection.plaque.geolocated?
	  } unless @person.born_at.blank?
	} unless @person.born_in.blank? and @person.born_at.blank?
	xml.died {
      xml.in { xml.text! @person.died_in.to_s } unless @person.died_in.blank?
      xml.at(:uri => location_url(@person.died_at.id)) {
	      xml.address @person.died_at.full_address
		    xml.geo(:reference_system => "WGS84", :latitude => @person.death_connection.plaque.latitude, :longitude => @person.death_connection.plaque.longitude)
      } unless @person.died_at.blank?
	  xml.age @person.age
	} unless @person.died_in.blank? and @person.died_at.blank?
	@person.roles.each do |role|
	  xml.role(:uri => role_url(role)) {
	    xml.text! role.name
	  }
	end
	@person.plaques.each do |plaque|
    xml.plaque(:uri => plaque_url(plaque)) {
      xml.title plaque.title
      xml.inscription plaque.inscription
      xml.colour plaque.colour.name unless plaque.colour.blank?
      xml.location(:uri => location_url(plaque.location.id)) {
        xml.text! plaque.location.full_address
      }
      xml.geo(:reference_system => "WGS84", :latitude => plaque.latitude, :longitude => plaque.longitude)  unless !plaque.geolocated?
	  }
	end
    xml.wikipedia(:uri => @person.default_wikipedia_url) unless @person.default_wikipedia_url.blank?
    xml.dbpedia(:uri => @person.default_dbpedia_uri) unless @person.default_dbpedia_uri.blank?
  }
}
