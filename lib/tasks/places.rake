
namespace "places:london" do
  desc "Assigns London places to the London area and cleans up their place names"
  task :clean_up => [:environment] do
    places = Place.find(:all, :conditions => {:area_id => nil})
    london_boroughs = ["Westminster", "Lambeth", "Tower Hamlets", "Richmond Upon Thames", "Hammersmith and Fulham", "Southwark", "Newham", "Camden", "Kensington and Chelsea", "Croydon", "Barnet", "Redbridge", "Islington", "Waltham Forest"]

    london = Area.find_by_name("London")
    place_regex = /(.*)\,?\s([A-Z]{1,2}\d{1,2})\s(.*)/

    london_boroughs_count = 0
    updated_places = 0
    
    places.each do |place| 

      london_boroughs.each do |borough|
        if place.name.ends_with?(" " + borough)
          london_boroughs_count += 1
          puts place.name  
          if place.name =~ place_regex
            place.name = place.name[place_regex, 1] + " " + place.name[place_regex, 3] + ", " + place.name[place_regex, 2] 
            place.area = london
            place.save
            puts "Saved London as area and re-ordered place name!"
            updated_places += 1
          else
            puts "NO MATCH! "
          end
          #puts place.name[, 2]
        end
      end
    end
    
    puts places.size.to_s + " places found. " + london_boroughs_count.to_s + " London boroughs found.  " + updated_places.to_s + " places updated." 
    
  end
end