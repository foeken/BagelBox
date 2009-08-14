class Scraper
  
  def self.installed?
    return !(`crontab -l 2>&1` =~ /rake scraper:run/).nil?
  end
  
  def self.run options={}
    SCRAPER_LOG.info( "Started scraping run" )        
    gather_filters(options)
    filter_and_download(options)
  end
  
  # Run through the various defined sources and scrape them for content to download.
  def self.filter_and_download options={}   
    accepted_data_files = []
    successful_filters  = []
    data_files          = scrapable_sources(false,options).collect(&:data).flatten
    
    SCRAPER_LOG.info( "Running filters on #{data_files.length} items" )
    
    data_files.each do |data_file|
      status = data_file.run_filters
      if status.first == :accepted
        accepted_data_files << data_file
        successful_filters += status.last
      end
    end    
    
    # Unfortunately there is a high risk of duplicate data_files in this list as new
    # torrents might spring up in multiple locations.    
    successful_filters.each do |filter|
      data_file_group = accepted_data_files.select{ |d| filter.match(d) == :positive_match }
      
      next if data_file_group.empty? # Can happen if they were handled before (with overlapping filters)
      
      # remove files from the accepted array, they can only be in ONE group.
      accepted_data_files -= data_file_group
      
      selected_data_file = nil
      # Handle the selection of which file to download now...
      if data_file_group.length == 1
        SCRAPER_LOG.info( "Single match for '#{filter.to_s}' on #{data_file_group.first.source.name}" )
        selected_data_file = data_file_group.first                        
      else        
        SCRAPER_LOG.info( "Multiple matches for '#{filter.to_s}' on #{data_file_group.collect{ |s| s.source.name }.to_sentence}" )
        
        sorted_data_file_group = DataFile.sort(data_file_group)
        selected_data_file = sorted_data_file_group.first
        SCRAPER_LOG.info( "Selected match with highest priority: #{sorted_data_file_group.first.source.name}" )                        
      end
      
      selected_data_file.download_in_background
      # selected_data_file.queue_to_download
      
      begin
        dff = selected_data_file.to_date_file_filter
        dff.source = selected_data_file.source
        dff.negative = true
        dff.singleton = false
        dff.save!
        SCRAPER_LOG.info( "Created new filter from '#{selected_data_file.source.name}': #{dff.to_s}" )
      rescue
        SCRAPER_LOG.info( "Skipped new filter from '#{selected_data_file.source.name}': #{dff.to_s}" )
      end
      
    end
    
    # We assume that each of the successful singular filters have been handled and can be deactivated.
    successful_filters = successful_filters.uniq.select{ |f| f.singleton }
    SCRAPER_LOG.info( "Deactivating #{successful_filters.length} succesful singleton filter(s)" )
    successful_filters.each{ |f| f.deactivate }
    
    handle_download_queues
    
    return true
    
  end
  
  # Creates a queue for each source that is queued, otherwise it just downloads all the files.
  def self.handle_download_queues
    Source.active.content.each do |source|
      if source.queued
        # Start downloading first file out of the queue is source is not already downloading
        source.data_files.queued.first.download_in_background( :follow_queue => true ) unless source.downloading?
      else
        # Download all the files right now
        source.data_files.queued.map(&:download)
      end
    end
  end
  
  # Run through the various filter sources and define new filters as we go along
  def self.gather_filters options={}
    scrapable_sources(true,options).each do |source|
      source.data.each do |data_file|
        begin
          unless data_file.data_file_filter
            data_file_filter = data_file.to_data_file_filter
            
            if data_file_filter
              data_file_filter.source = source
              data_file_filter.save!
              SCRAPER_LOG.info( "Created new filter from '#{data_file.source.name}': #{data_file_filter.to_s}" )
            else
              SCRAPER_LOG.info( "Skipped new filter from '#{data_file.source.name}', no match" )
            end
          end
        rescue
          SCRAPER_LOG.info( "Skipped new filter from '#{data_file.source.name}': #{data_file_filter.to_s}" )
          # Some filters might not be allowed (blank expressions, etc..) We don't care.
        end
      end
    end
  end
  
  # Select the sources that may be scraped at this moment
  def self.scrapable_sources filter, options={}
    sources = Source.active.find_all_by_filter_source(filter)
    
    return sources if options[:ignore_scrape_interval]
    
    default_scrape_interval = Setting.get("DEFAULT_SCRAPE_INTERVAL").to_i
    
    output = []
    sources.each do |source|
      if source.last_scraped_at
        output << source if Time.now - source.last_scraped_at > ( source.scrape_interval || default_scrape_interval )
      else
        output << source
      end
    end
      
    return output    
  end
  
end