class AddFailedToDataFile < ActiveRecord::Migration
  def self.up
    add_column :data_files, :failed, :boolean, :default => false
    add_column :data_files, :downloading, :boolean, :default => false
  end

  def self.down
    remove_column :data_files, :failed
    remove_column :data_files, :downloading
  end
end
