class SourceTypes::Rss < SourceTypes::SourceType  
  
  def self.name
    "Rss"
  end
  
  def self.download location, to
    `cd #{to} && wget -b #{location} --content-disposition --tries=5 --retry-connrefused --random-wait`
  end
  
  def self.data location,source=nil
    output = self.get_files(location,source).map do |parse_field,torrent_url|
      filename  = File.basename(parse_field)
      data_type = ::DataType.for(parse_field)      
      next if data_type && data_type.ignore
      
      ::DataFile.new( :filename => filename, 
                      :location => torrent_url, 
                      :source => source,
                      :data_type => data_type )
    end
    
    return output.compact
  end
  
  private
  
  def self.get_files location, source=nil
    
    begin    
      # Make sure we get the correct field
      if source && source.parsed_options[:rss_parse_field]
        rss_parse_field = source.parsed_options[:rss_parse_field]
      else
        rss_parse_field = :link
      end
      
      if source && source.parsed_options[:rss_link_field]
        rss_link_field = source.parsed_options[:rss_link_field]
      else
        rss_link_field = :link
      end
      
      if source && source.parsed_options[:rss_replace_in_link]
        rss_replace_in_link = source.parsed_options[:rss_replace_in_link].split(',')
      else
        rss_replace_in_link = nil
      end
      
      if source && source.parsed_options[:rss_replace_in_parse_field]
        rss_replace_in_parse_field = source.parsed_options[:rss_replace_in_parse_field].split(',')
      else
        rss_replace_in_parse_field = nil
      end
          
      output = []
      open(location) do |http|
        response = http.read
        result   = RSS::Parser.parse(response, false)
        result.items.each_with_index do |item, i|
          parse_field = item.send(rss_parse_field)
          parse_field.gsub!(/#{rss_replace_in_parse_field.first}/,rss_replace_in_parse_field.last) if rss_replace_in_parse_field          
          
          torrent_url = item.send(rss_link_field)
          torrent_url.gsub!(/#{rss_replace_in_link.first}/,rss_replace_in_link.last) if rss_replace_in_link          
          output << [parse_field,torrent_url]
        end  
      end
      return output
    rescue Exception => e
      SCRAPER_LOG.error( "[RSS] Failed to get file listing for #{location}: #{e.message}" )
      return []
    end
    
  end
  
end