Openplaques::Application.routes.draw do

  devise_for :users
  resources :users, :only => [:index, :show]

  # This site is designed to be RESTful, so most of the routes are defined here as resources.

  # These ones are related to plaques, but only in general, not a single plaque, and so use plaques as a prefix in the path. These have to be defined BEFORE the plaques resource.
  scope "/plaques" do
    resources :erected_in, :controller => :plaque_erected_years, :as => :plaque_erected_years, :only => [:index, :show]
    resource :all, :controller => :all_plaques, :as => :all_plaques, :only => [:show]
    resource :latest, :as => :latest, :controller => :plaques_latest, :only => [:show]
  end

  # e.g. /map?box=[51.6,-0.3],[51.4,-0.1]
  resource :map, :as => :map, :controller => :plaques_map, :only => [:show]

  # Main PLAQUE resources, and sub-resources
  resources :plaques do
    member do
      post 'parse_inscription'
      post 'unparse_inscription'
      post 'flickr_search'
      post 'flickr_search_all'
    end
    resource :location, :controller => :plaque_location, :only => [:edit]
    resource :erected, :controller => "PlaqueErected", :only => [:edit]
    resource :colour, :controller => :plaque_colour, :only => [:edit]
    resource :geolocation, :controller => :plaque_geolocation, :only => [:edit]
    resource :inscription, :controller => :plaque_inscription, :only => [:edit]
    resource :description, :controller => :plaque_description, :only => [:edit, :show]
    resource :language, :controller => "PlaqueLanguage", :only => [:edit]
    resources :connections, :controller => "PersonalConnections", :as => :connections
    resource :photos, :controller => "PlaquePhotos", :only => [:show]
  end

  resource :areas, :controller => :all_areas, :only => [:show]

  # These are the gazeteer (places) model based paths. They might change to become nested in future.
  resources :places, :controller => :countries, :as => :countries do
    resource :unphotographed, :controller => :unphotographed_plaques_by_country, :only => :show
    resources :areas do
      resource :unphotographed, :controller => :unphotographed_plaques_by_area, :only => :show
      resource :ungeolocated, :controller => :area_ungeolocated_plaques, :only => :show
    end
  end
  resources :locations, :only => [:show, :index, :edit, :update, :destroy]

  # These are all to do with the photos.
  resources :photos
  resources :photographers, :controller => "PhotoPhotographers", :only => [:index, :show]
  resources :licences, :only => [:index, :show]

  # These are the organisations
  resources :organisations

  # Verbs, roles and their connections to the plaques
  resources :verbs

  scope "/roles" do
    resources "a-z", :as => "roles_by_index", :controller => :roles_by_index, :only => [:show, :index]
  end

  resources :roles
  resources :personal_roles

  # People based resources:
  scope "/people" do
    resources "a-z", :controller => "people_by_index", :as => "people_by_index", :only => :show
    resources :born_on, :controller => :people_born_on, :as => "people_born_on", :only => [:index, :show]
    resources :died_on, :controller => :people_died_on, :as => "people_died_on", :only => [:index, :show]
    resources :born_in, :controller => :people_born_on, :as => "people_born_in", :only => [:index, :show]
    resources :died_in, :controller => :people_died_on, :as => "people_died_in", :only => [:index, :show]
    resources :alive_in, :controller => :people_alive_in, :as => "people_alive_in", :only => [:index, :show]
  end
  resources :people

  # Misc other resources
  resources :languages
  resources :colours
  resources :series
  resources :todo
  resources :picks

  # Convenience paths for search:
  match 'search' => "search#index"
  match 'search/:phrase' => "search#results"

  # Convenience paths for search:
  match 'match' => "match#index"

  # Convenience resources for important pages:
  resource :about, :controller => :pages, :id => "about", :only => :show
  resource :contact, :controller => :pages, :id => "contact", :only => :show
  scope "/about" do
    resource :data, :controller => :pages, :id => "data", :as => "about_the_data", :only => :show
  end
  resource :contribute, :controller => :pages, :id => "contribute", :as => "contribute", :only => :show
  resource :explore, :controller => :explore, :only => :show

  # Generic resource for all pages
  resources :pages

  # Convenience paths for login/logout/register:
  match 'logout' => 'sesssions#destroy', :as => :logout
  match 'login' => 'sesssions#new', :as => :login
  match 'register' => 'users#new', :as => :register


  # The Homepage
  root :to => "homepage#index"

end
