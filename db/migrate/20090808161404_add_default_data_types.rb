class AddDefaultDataTypes < ActiveRecord::Migration
  def self.up
    video     = DataType.new( :name => "Video file", :extension => "(avi|mpg|mkv)$", :ignore => false )
    torrent   = DataType.new( :name => "Torrent file", :extension => "(torrent)$", :ignore => false )
    rss_title = DataType.new( :name => "RSS Title",  :extension => "", :ignore => false )
    
    video.meta_matchers = File.read(RAILS_ROOT+'/db/migrate/default_video_matchers.txt')
    video.save
        
    torrent.meta_matchers = File.read(RAILS_ROOT+'/db/migrate/default_torrent_matchers.txt')
    torrent.save    
    
    # Ignored file types
    subtitles = DataType.create( :name => "Subtitle file", :extension => "(srt|idx)$", :ignore => true )
    info      = DataType.create( :name => "Info file", :extension => "(txt|nfo)$", :ignore => true )
    
    rss_title.meta_matchers = File.read(RAILS_ROOT+'/db/migrate/default_rss_title_matchers.txt')
    rss_title.save
  end

  def self.down
  end
end
