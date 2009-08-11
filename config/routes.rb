ActionController::Routing::Routes.draw do |map|
  map.resources :settings

  map.resources :data_file_filters

  map.resources :data_types

  map.resources :data_files

  map.resources :sources

  map.root :controller => "welcome"
  
  map.download 'data_files/:id/download', :controller => 'data_files', :action => 'download'
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
