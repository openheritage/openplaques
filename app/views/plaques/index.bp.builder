xml.page {
  xml.models {
    xml.tag!("model") {
      xml.instance(:id => "loc-info") {
        xml.tag!("location-chooser", :xmlns => "") {
        xml.search_location          
        }
      }
      xml.submission(:method => "post")
    }
  }
  xml.tag!("page-header") {
    xml.tag!("page-title", "Open Plaques")
  }
  xml.content {
    if params["_search_location_lat"] && params["_search_location_lon"]
      xml.module {
        xml.block "You are at " + params["_search_location_lat"].to_s + ", " + params["_search_location_lon"].to_s
        xml.map {
          xml.center {
            xml.latitude params["_search_location_lat"]
            xml.longitude params["_search_location_lon"]
          }
          xml.tag!("map-zoom", "2")
          xml.tag!("map-mode", "map")
          for plaque in @plaques 
            xml.tag!("map-point") {
              xml.location {
                xml.latitude plaque.latitude
                xml.longitude plaque.longitude
              }
              xml.placard {
                xml.tag!("layout-items") {
                  xml.block truncate(plaque.inscription, 40)
                }
                xml.tag!("load-page", :event => "activate", :page => "plaques/" + plaque.id.to_s + ".bp")
                
              }
            }            
          end
        }
        
      }
    end
    
    
    xml.module {
      xml.block "This is the mobile version of Open Plaques, a website about the historical blue plaques that commemorate historic people and events..."
      
      xml.tag!("location-chooser", :ref => "search_location") {
        xml.label "Set your location below"
      }
      
      xml.tag!("link-set", :appearance => "tab") {
        xml.tag!("inline-trigger") {
          xml.label "By person"
          xml.tag!("load-page", :event => "activate", :page => "people/a-z.bp")
        }
        xml.tag!("inline-trigger") {
          xml.label "By organisation"
          xml.tag!("load-page", :event => "activate", :page => "organisations.bp")
        }
        xml.tag!("inline-trigger") {
          xml.label "By area"
          xml.tag!("load-page", :event => "activate", :page => "areas.bp")
        }
      }

    }
  }
}