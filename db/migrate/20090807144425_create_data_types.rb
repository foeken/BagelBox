class CreateDataTypes < ActiveRecord::Migration
  def self.up
    create_table :data_types do |t|
      t.string :name
      t.string :extension
      t.boolean :ignore, :default => false
      t.text :meta_matchers
      t.timestamps
    end
  end

  def self.down
    drop_table :data_types
  end
end
