class ChangeDefaultDownloadDirectory < ActiveRecord::Migration
  def self.up
    remove_column :sources, :download_location
    add_column :sources, :download_location, :string, :default => ""
  end

  def self.down
    remove_column :sources, :download_location
    add_column :sources, :download_location, :string, :default => "download/"
  end
end
