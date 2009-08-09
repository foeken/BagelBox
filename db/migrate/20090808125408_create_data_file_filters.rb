class CreateDataFileFilters < ActiveRecord::Migration
  def self.up
    create_table :data_file_filters do |t|
      t.string :name
      t.text :expression
      t.references :source
      t.boolean :singleton, :default => false
      t.boolean :negative, :default => false
      t.boolean :active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :data_file_filters
  end
end
