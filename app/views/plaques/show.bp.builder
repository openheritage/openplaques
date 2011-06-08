xml.page {
  xml.tag!("page-header") {
    xml.tag!("title-bar") {
      xml.commands {
        xml.tag!("ui-command") {
          xml.title SITE_NAME
          xml.load(:event => "activate", :resource => "http://openplaques.bpapps.com/")
        }
      }
    }
    xml.tag!("page-title", "Plaque #" + @plaque.id.to_s)
  }
  xml.content {
    xml.module {
      xml.placard(:layout => "simple") {
        xml.tag!("layout-items") {
          xml.block @plaque.inscription
        }
      }
      if @plaque.geolocated?
        xml.map {
          xml.center {
            xml.latitude (@plaque.latitude.to_f + 0.0001).to_s
            xml.longitude (@plaque.longitude.to_f + 0.0001).to_s
          }
          xml.tag!("map-zoom", "2")
          xml.tag!("map-mode", "map")
          xml.tag!("map-point") {
            xml.location {
              xml.latitude @plaque.latitude
              xml.longitude @plaque.longitude
            }
            xml.placard {
              xml.tag!("layout-items") {
                xml.block "Find the plaque here"
              }
            }
          }
        }
      else
        xml.block "This plaque hasn't been geolocated. If you can find it, please photograph it, upload it to Flickr, geotag it and then tag it with openplaques:id=" + @plaque.id.to_s + " and we'll grab the geolocation from there.
        "
      end

    }

    xml.module {
      xml.header(:layout => "simple") {
        xml.tag!("layout-items") {
          xml.block({:class => "title"}, "Plaque Info")
        }
      }
      if @plaque.organisation
        xml.placard(:layout => "template") {
          xml.tag!("template-items", :format => "title-value") {
            xml.tag!("template-item", :field => "title") {
              xml.block "Erected by"
            }
            xml.tag!("template-item", :field => "value") {
              xml.block @plaque.organisation.name
            }
          }
        }
      end
      if @plaque.erected_at?
        xml.placard(:layout => "template") {
          xml.tag!("template-items", :format => "title-value") {
            xml.tag!("template-item", :field => "title") {
              xml.block "Erected in"
            }
            xml.tag!("template-item", :field => "value") {
              xml.block @plaque.erected_at.year.to_s
            }
          }
        }
      end

      if @plaque.colour
        xml.placard(:layout => "template") {
          xml.tag!("template-items", :format => "title-value") {
            xml.tag!("template-item", :field => "title") {
              xml.block "Colour"
            }
            xml.tag!("template-item", :field => "value") {
              xml.block @plaque.colour.name
            }
          }
        }
      end
    }

  }
}