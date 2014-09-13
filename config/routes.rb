Openplaques::Application.routes.draw do

  devise_for :users
  resources :users, :only => [:index, :show, :new, :create]

  # This site is designed to be RESTful, so most of the routes are defined here as resources.

  # These ones are related to plaques, but only in general, not a single plaque, and so use plaques as a prefix in the path. These have to be defined BEFORE the plaques resource.
  scope "/plaques" do
    resources :erected_in, :controller => :plaque_erected_years, :as => :plaque_erected_years, :only => [:index, :show]
    resource :latest, :as => :latest, :controller => :plaques_latest, :only => :show
    resource :unphotographed, :controller => :unphotographed_plaques, :only => :show
  end

  resources :plaques do
    member do
      post 'parse_inscription'
      post 'unparse_inscription'
      post 'flickr_search'
      post 'flickr_search_all'
    end
    resource :location, :controller => :plaque_location, :only => :edit
    resource :erected, :controller => :plaque_erected, :only => :edit
    resource :colour, :controller => :plaque_colour, :only => :edit
    resource :geolocation, :controller => :plaque_geolocation, :only => :edit
    resource :inscription, :controller => :plaque_inscription, :only => :edit
    resource :description, :controller => :plaque_description, :only => [:edit, :show]
    resource :language, :controller => :plaque_language, :only => :edit
    resources :connections, :controller => "PersonalConnections", :as => :connections
    resource :photos, :controller => :plaque_photos, :only => :show
    resource :talk, :controller => :plaque_talk, :only => :create
    resources :sponsorships
  end
  # map tiles are numbered using the convention at http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames
  match 'plaques/:zoom/:x/:y' => 'plaques#index', :constraints => { :zoom => /\d{2}/, :x => /\d+/, :y => /\d+/ }

  resources :areas, :controller => :all_areas, :only => :show do
    resource :plaques, :controller => :area_plaques, :only => :show
  end

  resources :places, :controller => :countries, :as => :countries do
    resource :plaques, :controller => :country_plaques, :only => :show
    resource :unphotographed, :controller => :unphotographed_plaques_by_country, :only => :show
    resources :areas do
      resource :unphotographed, :controller => :unphotographed_plaques_by_area, :only => :show
      resource :ungeolocated, :controller => :area_ungeolocated_plaques, :only => :show
    end
  end
  resources :locations, :only => [:show, :index, :edit, :update, :destroy]
 
  resources :photos
  resources :photographers, :as => :photographers, :only => [:create, :index, :show, :new]
  resources :licences, :only => [:index, :show]

  resources :organisations do
    resource :plaques, :controller => :organisation_plaques, :only => :show
  end
  resources :sponsorships

  resources :verbs

  scope "/roles" do
    resources "a-z", :controller => :roles_by_index, :as => "roles_by_index", :only => [:show, :index]
  end
  resources :roles
  resources :personal_roles

  scope "/people" do
    resources "a-z", :controller => :people_by_index, :as => "people_by_index", :only => :show
    resources :born_on, :controller => :people_born_on, :as => "people_born_on", :only => [:index, :show]
    resources :died_on, :controller => :people_died_on, :as => "people_died_on", :only => [:index, :show]
    resources :born_in, :controller => :people_born_on, :as => "people_born_in", :only => [:index, :show]
    resources :died_in, :controller => :people_died_on, :as => "people_died_in", :only => [:index, :show]
    resources :alive_in, :controller => :people_alive_in, :as => "people_alive_in", :only => [:index, :show]
  end
  resources :people do
    resource :plaques, :controller => :person_plaques, :only => :show
    resource :roles, :controller => :person_roles, :only => :show
  end

  resources :languages
  resources :colours
  resources :series
  resources :todo
  resources :picks

  # Convenience paths for search:
  match 'search' => "search#index"
  match 'search/:phrase' => "search#index"
  match 'match' => "match#index"

  # Convenience resources for important pages:
  resources :pages
  resource :about, :controller => :pages, :id => "about", :only => :show
  resource :contact, :controller => :pages, :id => "contact", :only => :show
  scope "/about" do
    resource :data, :controller => :pages, :id => "data", :as => "about_the_data", :only => :show
  end
  resource :contribute, :controller => :pages, :id => "contribute", :as => "contribute", :only => :show
  resource :explore, :controller => :explore, :only => :show

  # Convenience paths for login/logout/register:
  match 'logout' => 'sesssions#destroy', :as => :logout
  match 'login' => 'sesssions#new', :as => :login
  match 'register' => 'users#new', :as => :register

  # The Homepage
  root :to => "homepage#index"

  match '*path', :to => 'errors#not_found'

end
