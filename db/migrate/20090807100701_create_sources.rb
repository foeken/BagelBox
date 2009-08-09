class CreateSources < ActiveRecord::Migration
  def self.up
    create_table :sources do |t|
      t.string :name      
      t.boolean :active, :default => true
      t.string :location
      t.string :source_type
      t.string :category
      t.integer :priority, :default => 0
      t.string :priority_labels, :default => ""      
      t.text :options, :default => ""
      t.boolean :filter_source, :default => false
      t.boolean :negative, :default => false
      t.string :filter_labels
      t.datetime :last_scraped_at
      t.integer :scrape_interval, :default => 300
      t.string :download_location, :default => "downloads/"
      t.timestamps
    end
  end

  def self.down
    drop_table :sources
  end
end
