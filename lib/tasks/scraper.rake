require 'rubygems'

namespace :scraper do

  desc "Installs timed scraping (Default: Every 5 minutes, source scrape timer has preference)"
  task :install do    
    File.open("crontab.tmp", 'w') {|f| f.write("MAILTO=\"\"\n05 * * * * cd #{`pwd`.strip} && RAILS_ENV=production rake scraper:run") }
    `crontab crontab.tmp`
    `rm crontab.tmp`
  end
  
  desc "Uninstalls timed scraping (Warning: uninstalls every crontab, for granulur edit your crontab file!)"
  task :uninstall do
    `crontab -r`
  end

  desc "Runs the scraper"
  task :run => :environment do
    Scraper.run
  end
  
  desc "Runs the scraper"
  task :gather_filters => :environment do
    Scraper.gather_filters
  end
  
  namespace :clean do
    
    desc "Clean all filters created by a source"
    task :all => :environment do
      DataFileFilter.find(:all, :conditions => "source_id IS NOT NULL").map(&:destroy)
    end
    
    desc "Clean negative filters created by a source"
    task :negative => :environment do
      DataFileFilter.find_all_by_negative(true, :conditions => "source_id IS NOT NULL").map(&:destroy)
    end
    
    desc "Clean all positive filters created by a source"
    task :positive => :environment do
      DataFileFilter.find_all_by_negative(false, :conditions => "source_id IS NOT NULL").map(&:destroy)
    end
    
  end
  
end