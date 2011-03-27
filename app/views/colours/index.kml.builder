xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.kml(:xmlns=>"http://www.opengis.net/kml/2.2","xmlns:atom"=>"http://www.w3.org/2005/Atom") do
  xml.Document do
    xml.name "OpenPlaques.org"
    xml.atom :link, "href"=>"http://openplaques.org"
    xml.description "Commemorative plaques around the world"
    
    xml.Style(:id=>"plaqueIcon") do
      xml.IconStyle do
        xml.Icon do
          xml.href "http://openplaques.org/images/openplaques-icon.png"
        end
      end
    end

    for p in @parent
      if p.plaques.length > 0
        xml.Folder do
          xml.name p.name
          for plaque in p.plaques.geolocated
            kml(plaque, xml)
          end
        end
      end
    end
  end
end
