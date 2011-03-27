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
    xml.tag!("page-title", @area.name)
  }  
  xml.content {
    xml.module {
      xml.header(:layout => "simple") {
        xml.tag!("layout-items") {
          xml.block(:class => "title") { xml.text! @area.name }
        }
      }
      for plaque in @area.plaques
        xml.placard(:layout => "simple", :class => "link") {
         xml.tag!("layout-items") {
           xml.block(:class => "title") {
            xml.text! plaque.inscription
            }
         }
         xml.tag!("load-page", :event => "activate", :page => "plaques/" + plaque.id.to_s + ".bp")
        }
      end
    }
  }
}