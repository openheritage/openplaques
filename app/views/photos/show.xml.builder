xml.instruct! :xml, :version=>"1.0"
attributes = {:uri => photo_url(@photo.id)}
xml.openplaques(attributes){
  xml.photo(attributes) {
      xml.webpage(:uri => @photo.url)
      xml.fullsize(:uri => @photo.file_url)
      xml.thumbnail(:uri => @photo.thumbnail_url)
      xml.photographer(:uri => @photo.photographer_url) { 
      xml.text! @photo.photographer
    }
    if @photo.shot_name
      xml.shot(:order => @photo.shot_order) {
        xml.text! @photo.shot_name
      }
    end
    xml.licence(:uri => @photo.licence.url) {
      xml.text! @photo.licence.name
    }
    xml.plaque(:uri => plaque_url(@photo.plaque)) if @photo.plaque
  }
}