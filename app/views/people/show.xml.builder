xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  attributes = {:uri => person_url(@person), :updated_at => @person.updated_at.xmlschema}
  xml.person(attributes) {
    xml.name do
      xml.full @person.name
      xml.surname @person.surname
    end
    xml.born {
      xml.in { xml.text! @person.born_in.to_s } unless @person.born_in.blank?
      xml.at(:uri => location_url(@person.born_at.id)) {
	    xml.address @person.born_at.full_address
		xml.geo(:reference_system => "WGS84", :latitude => @person.birth_connection.plaque.latitude, :longitude => @person.birth_connection.plaque.longitude)
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
	  xml.location(:uri => location_url(plaque.location.id)) {
		xml.address plaque.location.full_address
	    xml.geo(:reference_system => "WGS84", :latitude => plaque.latitude, :longitude => plaque.longitude)
	  }
	}
	end
    xml.wikipedia_uri @person.default_wikipedia_url unless @person.default_wikipedia_url.blank?
    xml.dbpedia_uri @person.default_dbpedia_uri unless @person.default_dbpedia_uri.blank?
  }
}
