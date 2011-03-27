
namespace "inscriptions:unparse" do
  desc "Remove links from all the inscriptions"
  task :all => [:environment] do 
    unparsed_count = 0
    Plaque.find(:all).each do |plaque|
      if plaque.personal_connections.size > 0
        plaque.unparse_inscription
        print "."
        $stdout.flush                
        unparsed_count += 1
      end
    end
    puts "Unparsed the inscriptions of " + unparsed_count.to_s + " plaques."
  end
  
end

namespace "inscriptions:parse" do
  desc "Generate links from all the inscriptions"
  task :all => [:environment] do 
    parsed_count = 0
    parsed_successfully_count = 0
    Plaque.find(:all).each do |plaque|
      if plaque.personal_connections.size == 0
        plaque.parse_inscription
        print "."
        $stdout.flush
        parsed_count += 1
        plaque.reload
        if plaque.personal_connections.size > 0
          parsed_successfully_count += 1
        end
      end
    end
    puts "Parsed the inscriptions of " + parsed_count.to_s + " plaques."
    puts parsed_successfully_count.to_s + " successful."
  end
  
end