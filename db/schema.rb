# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090808230701) do

  create_table "data_file_filters", :force => true do |t|
    t.string   "name"
    t.text     "expression"
    t.integer  "source_id"
    t.boolean  "singleton",  :default => false
    t.boolean  "negative",   :default => false
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_files", :force => true do |t|
    t.string   "location"
    t.string   "filename"
    t.string   "directory"
    t.integer  "source_id"
    t.integer  "data_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_types", :force => true do |t|
    t.string   "name"
    t.string   "extension"
    t.boolean  "ignore",        :default => false
    t.text     "meta_matchers"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.boolean  "active",            :default => true
    t.string   "location"
    t.string   "source_type"
    t.string   "category"
    t.integer  "priority",          :default => 0
    t.string   "priority_labels",   :default => "0"
    t.text     "options",           :default => ""
    t.boolean  "filter_source",     :default => false
    t.boolean  "negative",          :default => false
    t.string   "filter_labels"
    t.datetime "last_scraped_at"
    t.integer  "scrape_interval",   :default => 300
    t.string   "download_location", :default => "downloads/"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
