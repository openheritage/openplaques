xml.instruct! :xml, :version=>"1.0" 
xml.openplaques(){
  xml.role(:id => role_url(@role.name), :created_at => @role.created_at.xmlschema, :updated_at => @role.updated_at.xmlschema){
    xml.name @role.name
    xml.people(:count => @role.people.size) {
      @role.people.each do |person|
        xml.person(:link => person_url(person)) {
          xml.name person.name
          xml.other_roles {
            person.roles.each do |role|
              xml.role(:link => role_url(role.name)) { 
                xml.name role.name
              } unless role == @role
            end            
          } unless person.roles.size == 1
        } 
      end
    }
  }
}
