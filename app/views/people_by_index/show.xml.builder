xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  @people.each do |person|
    xml.person(:link => person_url(person)) {
      xml.name {
        xml.full person.name
        xml.surname person.surname
      }
    }
  end
}
