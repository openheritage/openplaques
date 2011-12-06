xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  @people.each do |person|
	attributes = {:id => person_url(person), :created_at => person.created_at.xmlschema, :updated_at => person.updated_at.xmlschema}
	xml.person(attributes) {
	xml.name do
	  xml.full person.name
	  xml.surname person.surname
	end
	xml.born {
	  xml.in { xml.text! person.born_in.to_s } unless person.born_in.blank?
	  xml.at(:link => location_url(person.born_at.id)) {
		xml.address person.born_at.full_address
		xml.geolocation(:reference_system => "WGS84") {
		  xml.latitude person.birth_connection.plaque.latitude
		  xml.longitude person.birth_connection.plaque.longitude
		}
	  } unless person.born_at.blank?
	} unless person.born_in.blank? and person.born_at.blank?
	xml.died {
	  xml.in { xml.text! person.died_in.to_s } unless person.died_in.blank?
	  xml.at(:link => location_url(person.died_at.id)) {
		xml.address person.died_at.full_address
		xml.geolocation(:reference_system => "WGS84") {
		  xml.latitude person.death_connection.plaque.latitude
		  xml.longitude person.death_connection.plaque.longitude
		}
	  } unless person.died_at.blank?
	  xml.age person.age
	} unless person.died_in.blank? and person.died_at.blank?
	xml.wikipedia_uri person.default_wikipedia_url unless person.default_wikipedia_url.blank?
	xml.dbpedia_uri person.default_dbpedia_uri unless person.default_dbpedia_uri.blank?
	}
  end
}
