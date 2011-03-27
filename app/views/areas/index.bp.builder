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
    xml.tag!("page-title", "Areas")
  }
  xml.content {
    xml.module {
      xml.header(:layout => "simple") {
        xml.tag!("layout-items") {
          xml.block(:class => "title") { xml.text! "Areas" }
        }
      }
      for area in @areas
        xml.placard(:layout => "simple", :class => "link") {
         xml.tag!("layout-items") {
           xml.block(:class => "title") {
            xml.text! area.name + " (" + pluralize(area.plaques.size, "plaque") + ")"
            }
         }
         xml.tag!("load-page", :event => "activate", :page => "areas/" + area.id.to_s + ".bp")
        }
      end
    }
  }
}