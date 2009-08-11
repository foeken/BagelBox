class AddDownloadFieldsToDataFile < ActiveRecord::Migration
  def self.up
    add_column :data_files, :downloaded, :boolean, :default => false
    add_column :data_files, :downloaded_at, :datetime
  end

  def self.down
    remove_column :data_files, :downloaded_at
    remove_column :data_files, :downloaded
  end
end
