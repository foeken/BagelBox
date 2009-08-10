class AddDefaultSettings < ActiveRecord::Migration
  def self.up
    Setting.create!( :key => "DEFAULT_DOWNLOAD_PATH", :description => "Default download path", :value => "downloads/" )
    Setting.create!( :key => "DEFAULT_SCRAPER_CRON", :description => "Default scraper cron", :value => "*/5 * * * *" )
    Setting.create!( :key => "NUMBER_LABELS", :description => "Labels treated as numbers", :value => "season,episode,track" )
  end

  def self.down
    Setting.find_all_by_key(["DEFAULT_DOWNLOAD_PATH","DEFAULT_SCRAPER_CRON","NUMBER_LABELS"]).map(&:destroy)
  end
end
