ActionController::Routing::Routes.draw do |map|
  
  map.install 'settings/install_scraper',     :controller => 'settings', :action => 'install_scraper'
  map.uninstall 'settings/uninstall_scraper', :controller => 'settings', :action => 'uninstall_scraper'
  
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
