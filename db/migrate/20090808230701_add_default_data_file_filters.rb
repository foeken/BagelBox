class AddDefaultDataFileFilters < ActiveRecord::Migration
  def self.up
    DataFileFilter.create( :name => "No CAM/TS", :expression => "quality:\"CAM|TS\"", :negative => true )
  end

  def self.down    
  end
end
