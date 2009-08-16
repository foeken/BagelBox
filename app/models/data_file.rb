# DataFiles are the downloadables of BagelBox. A datafile can be of any DataType. Depending on that type
# it's meta data is gathered. It can be downloaded using the the DataFile's source type (Rss, Ftp, ...)
# download method. 
class DataFile < ActiveRecord::Base
  
  belongs_to :data_type  
  belongs_to :source
  validates_presence_of :data_type
    
  named_scope :failed, :conditions => ["failed = ?",true]
  named_scope :downloaded, :conditions => ["downloaded = ? AND failed = ?",true,false]
  named_scope :downloading, :conditions => ["downloading = ?",true]
  named_scope :queued, :conditions => ["downloaded = ? AND failed = ? AND downloading = ?",false,false,false]
  
  # Return the data file category based on the category of the source or if no source category is given
  # it will try to guess using the meta data.
  def category mt=nil
    return source.category.to_sym unless source.category.blank?        
    mt ||= meta_data    
    if mt.keys.include?(:season) || mt.keys.include?(:episode)
      return :tv_show
    elsif mt.keys.include?(:edition) || mt.keys.include?(:quality) || mt.keys.include?(:year)
      return :movie
    else
      return :unknown
    end          
  end
  
  # Return meta data for this file. Meta data is a hash containing labels specified in the data type
  # meta matchers. It is guaranteed to include the :filename and :category label.
  def meta_data options={}
    if data_type
      output = data_type.meta_data( self )
    else
      output = { :filename => filename, 
        :category => category.to_s,
        :location => location,
        :source_name => source.name }
    end
    
    if options[:skip]
      options[:skip].each do |label|
        output.delete(label)
      end
    end
    
    return output
    
  end
  
  # Returns the associated data file filter  
  def data_file_filter
    return DataFileFilter.find_by_name("[#{source.name}] #{meta_data[:filename]}")
  end
  
  # Convert this data type's meta tags to a data file filter
  def to_data_file_filter labels=nil
    
    raise "Connot convert to data file filter without labels" if !source.filter_labels && !labels
        
    labels = source.filter_labels.split(',').map(&:to_sym) unless labels
    
    df = DataFileFilter.new
    mt = meta_data
    
    # We can only create a filter if a match has occurred.
    return nil unless mt[:matcher]
    
    df.name       = "[#{source.name}] #{mt[:filename]}"
    df.active     = true
    df.negative   = source.negative
    df.singleton  = !source.negative
    
    expression  = []    
    labels.each do |label|
      if mt[label]
        
        if Setting.get("NUMBER_LABELS").split(',').include?(label.to_s)
          value = "^0?#{mt[label].to_i}$"
        else
          value = Regex.escape(mt[label])
        end
        
        expression << "#{label}:\"#{value}\""
      end
    end    
    df.expression = expression.join("\r\n")
    
    return df
  end
  
  # Runs the active data file filters and returns the status and affected filters.
  # Return values are :accepted, :rejected or :no_match
  def run_filters
    status            = :no_match
    matching_filters  = []    
    DataFileFilter.active.each do |filter|
      case filter.match(self)
        when :positive_match
          status = :accepted if status == :no_match
          matching_filters << filter
        when :negative_match
          status = :rejected
          matching_filters << filter
        when :no_match
          next
      end
    end
    return [status,matching_filters]
  end
  
  # Places this DataFile into the download queue
  def queue_to_download
    self.save!
  end
  
  # Download this DataFile in the background by forking this process
  def download_in_background options={}
    begin
      self.download( options.merge( { :fork => true } ) )
    rescue Exception => e
      SCRAPER_LOG.error( "Skipped dowloading '#{location}': #{e.message}" )
    end
  end
  
  # Download this DataFile using the SourceType's download method
  def download options={}
    raise "File is already downloading"   if self.downloading
    raise "File is already downloaded"    if self.downloaded
    
    reset_data_file_download_status
    
    if options[:fork]
      
      p = Process.fork do
        handle_download_result( source.download(location) )
        
        if options[:follow_queue] && !source.downloading?
          queue = source.data_files.queued
          queue.first.download_in_background( :follow_queue => true ) unless queue.empty?
        end        
      end
      
      Process.detach(p)
      return p
    else
      return handle_download_result( source.download(location) )
    end    
  end
  
  # Determine the priority score (an array of integers) based on each priority label
  def priority_label_score labels=nil
    output = []
    
    if labels
      selected_priority_labels = labels.map(&:to_s)
    elsif source.priority_labels.blank?
      case source.category
        when "movie"
          selected_priority_labels = "quality,edition"
        when "tv_show"
          selected_priority_labels = "quality"
        else
          selected_priority_labels = ""
      end
      
      selected_priority_labels = selected_priority_labels.split(',')
    else
      selected_priority_labels = source.priority_labels.split(',')
    end
        
    if data_type && !selected_priority_labels.blank?
      mt = meta_data            
      selected_priority_labels.each do |label|
       definition = data_type.get_definition(label.upcase.strip)
       if definition
         output << definition.split('|').index( mt[label.to_sym] ) || 1000000
       end
      end
    end
    return output
  end
  
  # Sort the data files based on their source priority and label score
  def self.sort data_files, labels=nil          
    return data_files.sort_by do |d|      
      y "#{d.filename}: [#{([(d.source.priority.blank? ? 1000000 : d.source.priority)] + d.priority_label_score(labels)).join(',')}]"
      [(d.source.priority.blank? ? 1000000 : d.source.priority)] + d.priority_label_score(labels)
    end
  end
  
  private
  
  # Resets the download, failed, downloading flags and nils the downloaded_at field
  def reset_data_file_download_status
    self.downloaded    = false
    self.downloaded_at = nil
    self.downloading   = true
    self.failed        = false
    self.save!
  end
  
  # Handle the succes/failure of a download by setting the appropiate flags
  def handle_download_result success
    self.downloading   = false
        
    if success      
      self.downloaded    = true
      self.downloaded_at = DateTime.now
    else
      self.failed        = true
    end    
    
    self.save!
    return success
  end
  
end
