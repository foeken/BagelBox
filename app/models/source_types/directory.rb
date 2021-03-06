class SourceTypes::Directory < SourceTypes::SourceType      
  
  def self.name
    "Directory"
  end
  
  def self.download location, to
    begin
      File.copy( File.expand_path(location), File.expand_path(to) )
      SCRAPER_LOG.info( "[DIRECTORY] Sucessfully copied file: #{location}" )
      return true
    rescue Exception => e
      SCRAPER_LOG.error( "[DIRECTORY] Failed to copy file '#{location}': #{e.message}" )
      return false
    end
  end
  
  def self.data location,source=nil
    output = get_files(location).map do |filename|
      data_type = ::DataType.for(File.basename(filename))      
      next if data_type.ignore    
      
      ::DataFile.new( :filename => File.basename(filename),
                      :directory => File.dirname(filename),
                      :location => "#{location}/#{filename}", 
                      :source => source,
                      :data_type => data_type )
    end
    
    return output.compact    
  end      
  
  private
  
  def self.get_files location
    expanded_location = File.expand_path(location) + "/"
    Dir["#{expanded_location}**/*.*"].reject{ |f| File.directory?(f) }.map{ |f| f.gsub!(expanded_location,'') }
  end
  
end