xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  @people.each do |person|
	  xml.person(:uri => person_url(person), :updated_at => person.updated_at.xmlschema) {
	    xml.name person.name
      xml.surname person.surname
      xml.born {
	      xml.in { xml.text! person.born_in.to_s } unless person.born_in.blank?
	      xml.at(:uri => location_url(person.born_at.id)) {
		      xml.text! person.born_at.full_address
	      } unless person.born_at == nil or person.born_at.blank?
      } unless person.born_in.blank? and person.born_at.blank?
      xml.died {
        xml.in { xml.text! person.died_in.to_s } unless person.died_in.blank?
        xml.at(:uri => location_url(person.died_at.id)) {
          xml.text! person.died_at.full_address
        } unless person.died_at.blank?
        xml.age person.age
	    } unless person.died_in.blank? and person.died_at.blank?
	    xml.wikipedia(:uri => person.default_wikipedia_url) unless person.default_wikipedia_url.blank?
	    xml.dbpedia(:uri => person.default_dbpedia_uri) unless person.default_dbpedia_uri.blank?
	  }
  end
}
