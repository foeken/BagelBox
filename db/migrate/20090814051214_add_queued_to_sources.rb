class AddQueuedToSources < ActiveRecord::Migration
  def self.up
    add_column :sources, :queued, :boolean, :default => false
  end

  def self.down
    remove_column :sources, :queued
  end
end
