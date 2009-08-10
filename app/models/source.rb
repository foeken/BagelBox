class Source < ActiveRecord::Base
  
  has_many :data_files, :dependent => :destroy
  has_many :data_file_filters, :dependent => :destroy
  
  def parsed_options
    output = {}
    options.scan(/(.*?):\"(.*?)\"/i).each do |label,value|      
      output[label.to_sym] = value
    end
    return output
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
    SCRAPER_LOG.info( "Downloading #{location} to '#{download_location}'" )
    source_type_object.download(location,download_location)
  end
  
end
