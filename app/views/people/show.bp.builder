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
    xml.tag!("page-title", @person.name)
  }
  xml.content {
    xml.module {
      roles = []
      @person.roles.each do |role|
      roles << role.name
      end
      xml.block({:halign => "center"}, roles.to_sentence)

      if @person.born_on?
        xml.placard(:layout => "template") {
          xml.tag!("template-items", :format => "title-value") {
            xml.tag!("template-item", :field => "title") {
              xml.block "Born in"
            }
            xml.tag!("template-item", :field => "value") {
              xml.block @person.born_on.year.to_s
            }
          }
        }
        if @person.died_on?
          xml.placard(:layout => "template") {
            xml.tag!("template-items", :format => "title-value") {
              xml.tag!("template-item", :field => "title") {
                xml.block "Died in"
              }
              xml.tag!("template-item", :field => "value") {
                xml.block @person.died_on.year.to_s
              }
            }
          }
      end
      for plaque in @person.plaques
        xml.placard(:layout => "simple", :class => "link") {
         xml.tag!("layout-items") {
           xml.block({:class => "title"}, "Plaque \#" + plaque.id.to_s)
         }
         xml.tag!("load-page", :event => "activate", :page => "plaques/" + plaque.id.to_s + ".bp")
        }
      end
    end
    }
  }
}