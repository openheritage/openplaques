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
    xml.tag!("page-title", "People by A-Z")
  }
  xml.content {
    xml.module {
      xml.tag!("link-set") {
        for letter in "a".."z"
            xml.tag!("inline-trigger") {
              xml.label letter
              xml.tag!("load-page", :event => "activate", :page => "people/a-z/" + letter + ".bp")
          }
        end      
      } 
    }
  }
}