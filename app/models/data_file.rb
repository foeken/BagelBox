class DataFile < ActiveRecord::Base
  
  belongs_to :data_type  
  belongs_to :source
  validates_presence_of :data_type
    
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
          value = mt[label]
        end
        
        expression << "#{label}:\"#{value}\""
      end
    end    
    df.expression = expression.join("\r\n")
    
    return df
  end
  
  # Runs the active data file filters and returns the status and affected filters.
  # Return values are :accepted , :rejected or :no_match
  def run_filters
    status            = :no_match
    matching_filters  = []    
    DataFileFilter.find_all_by_active(true).each do |filter|
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
      
  def queue_to_download
    self.save!
  end
  
  def download
    self.downloaded    = true
    self.downloaded_at = DateTime.now
    self.save!
    source.download(location)
  end
  
  def priority_label_score
    output = []
    
    if source.priority_labels.blank?
      case source.category
        when "movie"
          selected_priority_labels = "quality,edition"
        when "tv_show"
          selected_priority_labels = "quality"
        else
          selected_priority_labels = ""
      end        
    else
      selected_priority_labels = source.priority_labels
    end
        
    if data_type && !selected_priority_labels.blank?
      mt = meta_data            
      selected_priority_labels.split(',').each do |label|
       definition = data_type.get_definition(label.upcase.strip)
       if definition
         output << definition.split('|').index( mt[label.to_sym] ) || -1
       end
      end
    end
    return output
  end
  
  # Sort the data files based on their source priority and label score
  def self.sort data_files
    return data_files.sort_by{ |d| [d.source.priority] + d.priority_label_score }
  end
  
end
