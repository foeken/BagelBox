class CreateDataFiles < ActiveRecord::Migration
  def self.up
    create_table :data_files do |t|
      t.string :location
      t.string :filename
      t.string :directory
      t.references :source
      t.references :data_type
      t.timestamps
    end
  end

  def self.down
    drop_table :data_files
  end
end
