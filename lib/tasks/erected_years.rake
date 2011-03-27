
namespace "data:erected_years" do
  desc "Creates missing years in which no plaques were erected"
  task :fill_in => [:environment] do
    first_erected_year = PlaqueErectedYear.find(:first, :conditions => ["name <> '0'"],   :order => :name).name.to_i
    current_year = Date.today.year
   
    for year in first_erected_year..current_year
      @plaque_erected_year = PlaqueErectedYear.find_by_name(year)
      unless @plaque_erected_year
        @plaque_erected_year = PlaqueErectedYear.find_or_create_by_name(year)
        puts "Year " + year.to_s + "created. ID " + @plaque_erected_year.id.to_s
      end 
    
    end
  end
end
  