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
