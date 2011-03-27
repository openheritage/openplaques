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
      
      for person in @people
        xml.placard(:layout => "card", :class => "link") {
         xml.tag!("layout-items") {
           xml.block(:class => "title") {
            xml.text! person.name
            }
          roles = Array.new
          for role in person.roles
            roles << role.name
          end  
           xml.block(:class => "description") {
            xml.text! roles.to_sentence
           }          
         }
         xml.tag!("load-page", :event => "activate", :page => "people/" + person.id.to_s + ".bp")
        }
      end
    }
  }
}