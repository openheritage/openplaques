xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.osm(:version=>"0.6",:generator=>"openplaques.org") do
  xml.Document do
    for plaque in @plaques
      osm(plaque, xml)
    end
  end
end
