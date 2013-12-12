class StatsController < ApplicationController

  def show
    
    @plaques_count = Plaque.count
    @people_count = Person.count
    @countries_count = Area.count('country_id', :distinct => true)
    @places_count = Area.count   
    @languages_count = Plaque.count('language_id', :distinct => true) 
    @organisations_count = Organisation.count
    @photos_count = Photo.count
    @users_count = User.count

    respond_to do |format|
      format.html
      format.json {
        render :json => {
          'stats' => {
            'plaques_count' => @plaques_count,
            'people_count' => @people_count,
            'countries_count' => @countries_count,
            'places_count' => @places_count,
            'languages_count' => @languages_count,
            'organisations_count' => @organisations_count,
            'photos_count' => @photos_count,
            'users_count' => @users_count
          }
        }
      }
    end

  end

end
