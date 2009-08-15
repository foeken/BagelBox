class SourceTypes::Ftp < SourceTypes::SourceType      
  
  def self.name
    "Ftp"
  end
  
  def self.download location, to    
    output = []
    
    IO.popen("cd #{to} && wget #{location} --tries=5 --retry-connrefused --random-wait 2>&1", "r") do |pipe| 
      output << pipe.read
    end
    
    status = $?
    
    if status.success?
      SCRAPER_LOG.info( "[FTP] Sucessfully downloaded file: #{location}" )
      return true
    else
      SCRAPER_LOG.error( "[FTP] Failed to download file: #{location}" )
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
    
    begin
      uri = URI.parse(location)
    
      user = uri.user.blank? ? "Anonymous" : uri.user
      pass = uri.password
      path = uri.path.gsub(/^\//,'')
    
      Net::FTP.open(uri.host) do |ftp|
        ftp.login( user, pass )
        ftp.passive = true
        ftp.chdir(path) unless path.blank?      
        return ftp.nlst('*.*')
      end    
    rescue Exception => e
      SCRAPER_LOG.error( "[FTP] Failed to get file listing for #{location}: #{e.message}" )
      return []
    end
    
  end
  
end