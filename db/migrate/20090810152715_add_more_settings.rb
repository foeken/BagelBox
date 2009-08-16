class AddMoreSettings < ActiveRecord::Migration
  def self.up
    Setting.create!( :key => "DEFAULT_SCRAPE_INTERVAL", :description => "Default scrape interval", :value => "600" )
    remove_column :sources, :scrape_interval
    add_column :sources, :scrape_interval, :integer
    Source.all.map{ |s| s.update_attribute(:priority_labels,'') }
  end

  def self.down
    remove_column :sources, :scrape_interval
    add_column :sources, :scrape_interval, :integer, :default => 300
    Setting.find_by_key("DEFAULT_SCRAPE_INTERVAL").destroy
  end
end
