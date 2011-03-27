xml.page(:style => "list") {
  xml.tag!("page-header") {
    xml.tag!("title-bar") {
      xml.commands {
        xml.tag!("ui-command") {
          xml.title SITE_NAME
          xml.load(:event => "activate", :resource => "http://openplaques.bpapps.com/")
        }
      }
    }
    xml.tag!("page-title", "Organisation")
  }  
  xml.content {
    xml.module {
      xml.header(:layout => "simple") {
        xml.tag!("layout-items") {
          xml.block(:class => "title") { xml.text! "Organisations" }
        }
      }
      for organisation in @organisations
        xml.placard(:layout => "simple", :class => "link") {
         xml.tag!("layout-items") {
           xml.block(:class => "title") {
            xml.text! organisation.name
            }
         }
         xml.tag!("load-page", :event => "activate", :page => "organisations/" + organisation.id.to_s + ".bp")
        }
      end
    }
  }
}