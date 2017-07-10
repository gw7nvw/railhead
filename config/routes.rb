Railhead::Application.routes.draw do

#require 'resque/server'

#mount Resque::Server.new, at: "/resque"


root 'static_pages#home'
match "/people/editgrid", :to => "people#editgrid", :via => "get"
match "/people/data", :to => "people#data", :as => "person_data", :via => "get"
match "/people/db_action", :to => "people#db_action", :as => "person_db_action", :via => "get"
resources :people
match "/areas/editgrid", :to => "areas#editgrid", :via => "get"
match "/areas/data", :to => "areas#data", :as => "area_data", :via => "get"
match "/areas/db_action", :to => "areas#db_action", :as => "area_db_action", :via => "get"
resources :areas
match "/sources/editgrid", :to => "sources#editgrid", :via => "get"
match "/sources/data", :to => "sources#data", :as => "source_data", :via => "get"
match "/sources/db_action", :to => "sources#db_action", :as => "source_db_action", :via => "get"
resources :sources
match "/species/editgrid", :to => "species#editgrid", :via => "get"
match "/species/data", :to => "species#data", :as => "species_data", :via => "get"
match "/species/db_action", :to => "species#db_action", :as => "species_db_action", :via => "get"
resources :species
match "/collections/editgrid", :to => "collections#editgrid", :via => "get"
match "/collections/data", :to => "collections#data", :as => "data", :via => "get"
match "/collections/db_action", :to => "collections#db_action", :as => "db_action", :via => "get"
resources :collections
match "/seeds/editgrid", :to => "seeds#editgrid", :via => "get"
match "/seeds/data", :to => "seeds#data", :as => "seed_data", :via => "get"
match "/seeds/db_action", :to => "seeds#db_action", :as => "seed_db_action", :via => "get"
resources :seeds
match "/seedlings/editgrid", :to => "seedlings#editgrid", :via => "get"
match "/seedlings/data", :to => "seedlings#data", :as => "seedling_data", :via => "get"
match "/seedlings/db_action", :to => "seedlings#db_action", :as => "seedling_db_action", :via => "get"
resources :seedlings
match "/plantings/editgrid", :to => "plantings#editgrid", :via => "get"
match "/plantings/data", :to => "plantings#data", :as => "planting_data", :via => "get"
match "/plantings/db_action", :to => "plantings#db_action", :as => "planting_db_action", :via => "get"
resources :plantings
match "/destinations/editgrid", :to => "destinations#editgrid", :via => "get"
match "/destinations/data", :to => "destinations#data", :as => "destination_data", :via => "get"
match "/destinations/db_action", :to => "destinations#db_action", :as => "destination_db_action", :via => "get"
resources :sources
resources :destinations
resources :password_resets, only: [:new, :create, :edit, :update]
resources :sessions, only: [:new, :create, :destroy]

  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/styles.js', to: "maps#styles", via: 'get', as: "styles", defaults: { format: "js" }
  match 'layerswitcher', to: "maps#layerswitcher", via: 'get'
  match '/signin',  to: 'sessions#new',         via: 'get'
  match '/signout', to: 'sessions#destroy',     via: 'delete'
  match '/about',   to: 'static_pages#about',   via: 'get'
  match '/sessions', to: 'static_pages#home',    via:'get'

end
