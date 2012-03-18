xml.instruct! :xml, :version=>"1.0"
xml.openplaques(){
  @organisations.each do |organisation|
    xml.organisation(:uri => organisation_url(organisation)) {
      xml.name organisation.name
    }
  end
}