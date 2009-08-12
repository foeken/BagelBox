ActionController::Routing::Routes.draw do |map|
    
  map.resources :settings, :except => [:show], :collection => { :install_scraper => :get, :uninstall_scraper => :get }                                                                
  map.resources :data_file_filters, :except => [:show]
  map.resources :data_types, :except => [:show]
  map.resources :data_files, :except => [:show], :member => { :download => :get }
  map.resources :sources, :collection => { :download => :post }
  map.resources :log, :only => [:index]
  
  map.root :controller => "welcome"
      
end
