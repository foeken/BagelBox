class AddDefaultSources < ActiveRecord::Migration
  def self.up
    
    # Content sources
    
    Source.create(  :name => 'Pirate Bay (TV Shows)',
                    :location => "http://rss.thepiratebay.org/205",
                    :category => "tv_show",
                    :source_type => "Rss",
                    :priority_labels => "quality",
                    :priority => 600 )
                    
    Source.create(  :name => 'Pirate Bay (Movies)',
                    :location => "http://rss.thepiratebay.org/201",
                    :category => "movie",
                    :source_type => "Rss",
                    :priority_labels => "quality,edition",
                    :priority => 600 )
            
    Source.create(  :name => 'Pirate Bay (HD-Movies)', 
                    :location => "http://rss.thepiratebay.org/207",
                    :category => "movie",
                    :source_type => "Rss",
                    :priority_labels => "quality,edition",
                    :priority => 500 )
                    
    Source.create(  :name => 'Pirate Bay (HD-TV Shows)', 
                    :location => "http://rss.thepiratebay.org/208",
                    :category => "tv_show",
                    :source_type => "Rss",
                    :priority_labels => "quality",
                    :priority => 500 )

    Source.create(  :name => 'Pirate Bay (DVDR Movies)',
                    :location => "http://rss.thepiratebay.org/202",
                    :category => "movie",
                    :source_type => "Rss",
                    :priority_labels => "quality,edition",
                    :priority => 400 )
                                
    Source.create(  :name => 'Mininova (TV Shows)',
                    :location => "http://www.mininova.org/rss.xml?cat=8",
                    :category => "tv_show",
                    :source_type => "Rss",
                    :priority_labels => "quality",
                    :options => "rss_parse_field:\"title\"\r\nrss_replace_in_link:\"/tor/,/get/\"",
                    :priority => 300 )
                    
    Source.create(  :name => 'Mininova (Movies)',
                    :location => "http://www.mininova.org/rss.xml?cat=4",
                    :category => "movie",
                    :source_type => "Rss",
                    :priority_labels => "quality,edition",
                    :options => "rss_parse_field:\"title\"\r\nrss_replace_in_link:\"/tor/,/get/\"",
                    :priority => 300 )

    Source.create(  :name => 'Demonoid (Movies)',
                    :location => "http://static.demonoid.com/rss/1.xml",
                    :category => "movie",
                    :source_type => "Rss",
                    :priority_labels => "quality,edition",
                    :options => "rss_parse_field:\"title\"\r\nrss_replace_in_link:\"/files/details/,/files/download/HTTP/\"",
                    :priority => 200 )

    Source.create(  :name => 'Demonoid (TV Shows)',
                    :location => "http://static.demonoid.com/rss/3.xml",
                    :category => "tv_show",
                    :source_type => "Rss",
                    :priority_labels => "quality",
                    :options => "rss_parse_field:\"title\"\r\nrss_replace_in_link:\"/files/details/,/files/download/HTTP/\"",
                    :priority => 200 )
    
    Source.create(  :name => 'BT-Chat.com', 
                    :location => "http://rss.bt-chat.com",
                    :category => "",
                    :source_type => "Rss",
                    :priority => 100,
                    :priority_labels => "quality,edition",
                    :options => "rss_parse_field:\"title\"" )
        
    # Filter sources
    
    Source.create(  :name => 'Local movies',
                    :location => "~/Movies",
                    :category => "",
                    :source_type => "Directory",
                    :filter_source => true,
                    :negative => true,
                    :filter_labels => "title,season,episode,category",
                    :scrape_interval => 60 )
                    
    Source.create(  :name => 'Myepisodes.com (NEEDS YOUR RSS URL!)',
                    :location => "http://myepisodes.com/rss.php?feed=mylist&showignored=0&sort=asc",
                    :category => "tv_show",
                    :source_type => "Rss",
                    :options => "rss_parse_field:\"title\"",
                    :filter_source => true,
                    :active => false,
                    :negative => false,
                    :filter_labels => "title,season,episode,category",
                    :scrape_interval => 7200 )
  end

  def self.down
  end
end
