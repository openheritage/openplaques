xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  attributes = {:id => person_url(@person), :created_at => @person.created_at.xmlschema, :updated_at => @person.updated_at.xmlschema}
  attributes[:wikipedia_url] = @person.wikipedia_url unless @person.wikipedia_url.blank?
  attributes[:dbpedia_uri] = @person.dbpedia_uri unless @person.dbpedia_uri.blank?
  xml.person(attributes) {
    xml.name do
      xml.full @person.name
      xml.surname @person.surname
    end
    xml.tag!("born-in") { xml.text!(@person.born_in.to_s) } unless @person.born_in.blank?
    xml.tag!("born-at") { xml.text!(@person.born_at.to_s) } unless @person.born_at.blank?
    xml.tag!("died-in") { xml.text!(@person.died_in.to_s) } unless @person.died_in.blank?
    xml.tag!("died-at") { xml.text!(@person.died_at.to_s) } unless @person.died_at.blank?
    xml.roles {
      @person.roles.each do |role|
        xml.role(:id => role_url(role)) {
          xml.name role.name
        }
      end
    }
    xml.plaques {
      @person.plaques.each do |plaque|
        xml.plaque(:id => plaque_url(plaque)) {
          xml.title plaque.title
        }
      end
    }
  }
}
