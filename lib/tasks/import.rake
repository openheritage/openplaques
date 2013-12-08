namespace "import" do

  desc "Import some example plaques - useful for local development"
  task :plaque_examples => [:environment] do

    3.times do 

      first_names = ["Dead Poets", "Philosophers", "Devon", "National Heritage", "Comic Book", "London", "Amusing History", "Engineering", "Chemistry", "Architecture", "Poetry", "Literature", "American", "Canadian"]
      last_names = ["Society", "Institute", "Rotary Club", "Council", "Club", "Civic Trust", "Royal Society"]

      organisation = Organisation.new

      organisation.name = first_names[rand(first_names.size - 1)] + " " + last_names[rand(last_names.size - 1)]

      organisation.slug = organisation.name.downcase.gsub(" ", "_")

      organisation.save

    end

    countries = Country.all    

    10.times do 

      area_names = ["Newtown", "Springfield", "London", "Franklin", "Washington", "Greenville", "Chester", "Flint", "Georgetown", "Newport", "Centrevill", "Clinton"]

      area = Area.new
      area.name = area_names[rand(area_names.size - 1)]
      area.slug = area.name.downcase
      area.country = countries[rand(countries.size - 1)]

      area.save

    end

    100.times do

      first_names = ["Alex", "Ed", "Fran", "Sidney", "Terry", "Jamie", "Robin", "Mel", "Sam", "Vivian", "Joss", "Frankie"]
      last_names = ["Anderson", "Adams", "Armstrong", "Arnold", "Rowntree", "Blair", "Donovan", "Lennon", "Westwood", "Richardson", "Blake", "Warhol", "Churchill", "McCartney", "Donaldson", "Steptoe", "Bishop", "Khan"]

      person_name = [first_names[rand(first_names.size - 1)],
        last_names[rand(last_names.size - 1)]].join(' ')

      person = Person.new
      person.name = person_name
      person.born_on = Date.parse('1950-01-01') - rand(360 * 100).days
      person.died_on = Date.parse('2013-01-01') - rand(360 * 50).days
      person.save 

    end

    people = Person.all
    areas = Area.all
    organisations = Organisation.all
    colours = Colour.all

    200.times do

      titles = ["", "Mr", "Mrs", "The Right Honorable", "Dame", "Sir", "", "Former Prime Minister", "Miss", "Mr"]
      verbs = ["lived", "worked", "sung", "wrote poetry", "devised plays", "watered the garden", "was born", "died", "hid", "thought deeply", "ruled the country", "tripped", "lived", "lived and worked", "was born and lived"]
      places = ["here", "here", "here", "here", "here", "near here", "on this spot", "in this house"]

      verb = verbs[rand(verbs.size - 1)]


      location = Location.new
      location.area = areas[rand(areas.size - 1)]
      location.country = location.area.country
      location.name = rand(999).to_s + " " + ["New", "Old", "City", "Central"][rand(4)] + " " + ["Street", "Road", "Allex"][rand(3)]
      location.save

      person = people[rand(people.size - 1)]

      plaque = Plaque.new

      plaque.user = User.first

      plaque.latitude = BigDecimal.new(50) + rand(10000000000).to_f / 5000000000.to_f
      plaque.longitude = BigDecimal.new(0) + rand(10000000000).to_f / 5000000000.to_f
      plaque.organisations << organisations[rand(organisations.size - 1)]

      plaque.inscription = [
        titles[rand(titles.size - 1)], 
        person.name,
        verb,
        places[rand(places.size - 1)],
        ].join(' ')

      plaque.location = location

      plaque.colour = colours[rand(colours.size - 1)]

      plaque.save!

      personal_connection = PersonalConnection.new
      personal_connection.plaque = plaque
      personal_connection.person = person
      personal_connection.location = location
      personal_connection.verb = Verb.find_or_create_by_name(verb)
      personal_connection.save!

    end

  end
end