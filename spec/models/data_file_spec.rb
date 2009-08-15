require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DataFile do

  before(:each) do
    
    Setting.delete_all
    DataType.delete_all
    
    number_labels = Setting.create!( :key => "NUMBER_LABELS", :value => "season,episode" )
    
    @video         = DataType.create!( :name => "Video", :meta_matchers => File.read("db/migrate/default_video_matchers.txt") )
    @torrent       = DataType.create!( :name => "Torrent", :meta_matchers => File.read("db/migrate/default_torrent_matchers.txt") )
    
    @torrent_site = Source.create!( :name => "Torrents R us", :source_type => "Rss", :download_location => "spec/downloads" )
    
    @tv_show_filenames = [ "Eureka.S03E14.720p.HDTV.x264-SiTV.[eztv].torrent",
                           "Psych.S04E02.He.Dead.TS.XviD-FQM.[VTV].torrent",
                           "Mental.S01E13.Bad.Moon.Rising.SD.XviD-FQM.[eztv].torrent",
                           "In.Plain.Sight.S02E15.REPACK.HDTV.XviD-2HD.[eztv].torrent",
                         ]
                        
    @movie_filenames   = [ "Lassie (2005) [DVDRip]",
                           "X-Men Origins Wolverine (2009) DVDRip Xvid",
                           "Knowing 2009 1080p BluRay DTS x264-DON[No Rars]"
                         ]
    
    # Always download the BagelBox LICENCE file from GitHub
    location = "http://github.com/foeken/BagelBox/raw/c0b3251ad74aadfe5455bafe7c7283e80893ce54/LICENSE"
    
    (@tv_show_filenames+@movie_filenames).each do |filename|
      DataFile.create!( :data_type => @torrent, :source => @torrent_site, :filename => filename, :location => location )
    end
    
  end

  it "should be be able to list downloaded files" do
    DataFile.all.map{ |d| d.update_attribute(:downloaded, true) }
    DataFile.downloaded.should have(DataFile.count).items
  end
  
  it "should be be able to list failed files" do
    DataFile.all.map{ |d| d.update_attribute(:failed, true) }
    DataFile.failed.should have(DataFile.count).items
  end
  
  it "should be be able to list queued files" do
    DataFile.queued.should have(DataFile.count).items
  end
  
  it "should be be able to list downloading files" do
    DataFile.all.map{ |d| d.update_attribute(:downloading, true) }
    DataFile.downloading.should have(DataFile.count).items
  end
  
  it "should be able to determine category based on source category" do
    @torrent_site.update_attribute(:category,"movie")
    DataFile.all.map(&:category).uniq.should eql([:movie])
  end
  
  it "should be able to automatically determine category based on meta data" do
    DataFile.find_all_by_filename(@tv_show_filenames).map(&:category).uniq.should eql([:tv_show])
    DataFile.find_all_by_filename(@movie_filenames).map(&:category).uniq.should eql([:movie])
  end
  
  it "should be able to generate meta data based on the data type of the data file" do
    # Just a basic test, the goal is not to spec out correct meta_tag behaviour here. See DataType.
    meta_data = DataFile.find_by_filename(@tv_show_filenames.first).meta_data
    
    meta_data[:title].should eql("Eureka")
    meta_data[:season].to_i.should eql(3)
    meta_data[:episode].to_i.should eql(14)
    meta_data[:quality].should eql("720p")
  end
  
  it "should be able to determine if any of the active filters match this data file" do
    
    DataFile.first.run_filters.first.should eql(:no_match)
    
    filter = DataFile.first.to_data_file_filter [:title]
    filter.source = @torrent_site
    filter.save!
    
    DataFile.first.run_filters.first.should eql(:accepted)
    
    filter.negative = true
    filter.save!
    
    DataFile.first.run_filters.first.should eql(:rejected)
    
  end
  
  it "should be able to convert any data file to a data file filter" do
    filter = DataFile.find_by_filename(@tv_show_filenames.first).to_data_file_filter( [:title,:season,:episode,:category] )
    
    filter.expression.should eql("title:\"Eureka\"\r\nseason:\"^0?3$\"\r\nepisode:\"^0?14$\"\r\ncategory:\"tv_show\"")
    filter.source.should be_nil
    filter.singleton.should be_true
    filter.negative.should be_false
    filter.active.should be_true
  end
  
  it "should be able to find a data file filter that was created based on this data file" do
    data_file     = DataFile.find_by_filename(@tv_show_filenames.first)
    filter        = data_file.to_data_file_filter( [:title,:season,:episode,:category] )
    filter.source = @torrent_site
    filter.save!
    
    data_file.data_file_filter.should eql(filter)    
  end
  
  it "should be able to queue this file for downloading" do
    # it should simply save the DataFile
    data_file = DataFile.first
    data_file.location = "Http://localhost/test.torrent"    
    data_file.queue_to_download
    data_file.reload
    data_file.location.should eql("Http://localhost/test.torrent")
  end
  
  it "should be able to download a file in the background" do
    # Rspec does not handle forking all that well ;)
  end
  
  it "should be able to download a file based on the source type" do
    DataFile.first.download
    File.exists?("#{RAILS_ROOT}/spec/downloads/LICENSE").should be_true
    File.delete("#{RAILS_ROOT}/spec/downloads/LICENSE")
  end
  
  it "should be able to determine the priority score of any data file based on the given labels" do
    data_file = DataFile.find_by_filename(@tv_show_filenames.first)
    score     = data_file.priority_label_score( [:quality] )
    expected  = @torrent.get_definition("QUALITY").split("|").index(data_file.meta_data[:quality])
    score.should eql([expected])
  end
  
  it "should be able to sort an array of data files based on their priority score" do
    sorted_data = DataFile.sort DataFile.find_all_by_filename(@tv_show_filenames), [:quality]
    sorted_data.last.meta_data[:quality].should eql("TS")    
  end
  
end