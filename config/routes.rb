Openplaques::Application.routes.draw do
  
  
  devise_for :users
  resources :users, :only => [:index, :show]
  
  
  # This site is designed to be RESTful, so most of the routes are defined here as resources.

  # These ones are related to plaques, but only in general, not a single plaque, and so use plaques as a prefix in the path. These have to be defined BEFORE the plaques resource.
  
  scope "/plaques" do
  
    resources :erected_in, :controller => :plaque_erected_years, :as => :plaque_erected_years, :only => [:index, :show]
    resource :all, :controller => :all_plaques, :as => :all_plaques, :only => [:show]
    resource :map, :as => :map, :controller => :plaques_map, :only => [:show]
    resource :latest, :as => :latest, :controller => :plaques_latest, :only => [:show]

  end
  
  # Main PLAQUE resources, and sub-resources
  resources :plaques do
    member do
      post 'parse_inscription'
      post 'unparse_inscription'
      post 'flickr_search'
      post 'flickr_search_all'
    end
    resource :location, :controller => "PlaqueLocation", :only => [:edit]
    resource :erected, :controller => "PlaqueErected", :only => [:edit]
    resource :colour, :controller => :plaque_colour, :only => [:edit]
    resource :geolocation, :controller => "PlaqueGeolocation", :only => [:edit]
    resource :inscription, :controller => "PlaqueInscription", :only => [:edit]
    resource :description, :controller => :plaque_description, :only => [:edit, :show]
    resource :language, :controller => "PlaqueLanguage", :only => [:edit]
    resources :personal_connections, :controller => "PersonalConnections", :as => :connections
  end

  resource :areas, :controller => :all_areas, :only => [:show]

  # These are the gazeteer (places) model based paths. They might change to become nested in future.
  resources :places, :controller => :countries, :as => :countries do
    resource :unphotographed, :controller => :unphotographed_plaques_by_country    
    resources :areas do
      resource :unphotographed, :controller => :unphotographed_plaques_by_area, :only => [:show]
      resource :ungeolocated, :controller => :area_ungeolocated_plaques, :only => [:show]
    end
  end
  resources :locations

  # These are all to do with the photos.
  resources :photos
  resources :photographers, :controller => "PhotoPhotographers"
  resources :licences

  # These are the organisations:
  resources :organisations

  # Verbs, roles and their connections to the plaques
  resources :verbs
  
  
  scope "/roles" do
    resources "a-z", :as => "roles_by_index", :controller => :roles_by_index    
  end
  
  resources :roles
  resources :connections
  resources :personal_roles

  # People based resources:
  scope "/people" do
    resources "a-z", :controller => "people_by_index", :as => "people_by_index"
    resources :born_on, :controller => :people_born_on, :as => "people_born_on", :only => [:index, :show]
    resources :died_on, :controller => :people_died_on, :as => "people_died_on", :only => [:index, :show]
  end
  resources :people


  # Misc other resources
  resources :languages
  resources :colours

  resources :todo

 
  # Convenience paths for search:
  match 'search' => "search#index"
  match 'search/:phrase' => "search#results"

  # Convenience paths for pages:
  
  # FIXME: not sure how to do a named path for a specific ID in Rails 3
  # match "contact"  => "pages#show", :as => :contact

  # FIXME: not sure how to do a named path for a specific ID in Rails 3
  # about_data "/about/data" => "pages#show", :as => :about_data

  # FIXME: not sure how to do a named path for a specific ID in Rails 3
  # match "media_coverage" => "pages#show", :as => :media_coverage

  # FIXME: not sure how to do a named path for a specific ID in Rails 3
  # match  "about" => "pages#show", :as => :about 


  resources :pages

  # Convenience paths for login/logout/register:
  match 'logout' => 'sesssions#destroy', :as => :logout
  match 'login' => 'sesssions#new', :as => :login
  match 'register' => 'users#new', :as => :register


  # The Homepage
  root :to => "homepage#index"

end
