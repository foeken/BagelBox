class Source < ActiveRecord::Base
  
  has_many :data_files, :dependent => :destroy
  has_many :data_file_filters, :dependent => :destroy
  
  named_scope :filter, :conditions => ["filter_source = ?",true]
  named_scope :content, :conditions => ["filter_source = ?",false]    
  named_scope :active, :conditions => ["active = ?",true]
  named_scope :queued, :conditions => ["queued = ?",true]
    
  def parsed_options
    output = {}
    options.scan(/(.*?):\"(.*?)\"/i).each do |label,value|      
      output[label.to_sym] = value
    end
    return output
  end
  
  def downloading?
    return !data_files.downloading.empty?
  end
  
  def start_downloading options={}
    if queued || options[:force_queued]
      # Handle queue one-by-one
      if self.downloading?
        SCRAPER_LOG.error( "Skipped download start for '#{self.name}': Source is already downloading." )
      elsif !self.data_files.queued.empty? 
        self.data_files.queued.first.download_in_background( :follow_queue => true )
      end
    else
      # Download all queued file right now
      self.data_files.queued.each do |file|
        begin 
          file.download
        rescue Esception => e
          SCRAPER_LOG.error( "Skipped dowloading '#{file}': #{e.message}" )
        end
      end
    end
  end
  
  def uri
    URI.parse(location)
  end
  
  def source_type_object
    SourceTypes::SourceType.build(source_type)
  end
  
  def data options={}
    SCRAPER_LOG.info( "Gathering data from: '#{name}'" )
    self.update_attribute(:last_scraped_at, Time.now) unless options[:manual_scrape]
    source_type_object.data(location,self)
  end
  
  def download location
    to = download_location.blank? ? Setting.get("DEFAULT_DOWNLOAD_PATH") : download_location
    SCRAPER_LOG.info( "Downloading #{location} to '#{to}'" )    
    return source_type_object.download(location,to)
  end
  
end
