class AddPidToDataFile < ActiveRecord::Migration
  def self.up
    add_column :data_files, :pid, :integer
  end

  def self.down
    remove_column :data_files, :pid
  end
end
