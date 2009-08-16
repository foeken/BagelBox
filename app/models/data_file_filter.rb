class DataFileFilter < ActiveRecord::Base
  
  belongs_to :source
  
  validates_presence_of :expression  
  validate :no_duplicate_filters

  named_scope :active,   :conditions => ["active = ?",true]
  named_scope :negative, :conditions => ["negative = ?",true]
  named_scope :positive, :conditions => ["negative = ?",false]
  
  after_save :deactivate_clashing_filters
  
  # Activate this filter, including it in matches
  def activate
    self.active = true
    self.save!
  end
  
  # Disable this filter, exclusing it in matches
  def deactivate
    self.active = false
    self.save!
  end
  
  def clashes options={}    
    
    if options[:include_deactivated]
      base = DataFileFilter
    else
      base = DataFileFilter.active
    end
    
    if self.negative
      base.positive.select{ |d| self.expression_clash?(d) }
    else
      base.negative.select{ |d| d.expression_clash?(self) }
    end
  end
  
  # Determines if the expressions clash
  def expression_clash? other
    my_expression    = parsed_expression
    other_expression = other.parsed_expression  
        
    if !(my_expression.keys & other_expression.keys).empty?
      # If we have any matching keys
      
      if my_expression.keys.length > other_expression.keys.length
        # My expression is more specific
        return false
      elsif other_expression.keys.length > my_expression.keys.length
        # My expression is more generic if the keys that are the same MATCH
        (my_expression.keys & other_expression.keys).each do |key|
          return false if my_expression[key].strip.downcase != other_expression[key].strip.downcase
        end        
        return true
      elsif my_expression.keys.length == other_expression.keys.length
        # Same expression, let's look at the values
        different = false
        my_expression.each do |key,value|
          if other_expression[key] && value.strip.downcase != other_expression[key].strip.downcase
            different = true
            # If have different values, so we don't clash!
            return false
          end
        end     
        return true
      end
    end
    # Different sets of keys
    return false    
  end
  
  # Returns the expression string in hash format
  def parsed_expression options={}
    output = {}
    expression.scan(/(.*?):\"(.*?)\"/i).each do |label,value|
      value = value.gsub("^0?","").gsub("$","") if value && options[:real_numbers]
      output[label.to_sym] = value
    end
    return output
  end
  
  # Determine if any filter matches the given DataFile or meta data hash
  def self.match data_file=nil, meta_data={}, options={}
    filters = options[:include_inactive] ? DataFileFilter.all : DataFileFilter.find_all_by_active(true)
    return filters.reject{ |f| f.match(data_file,meta_data) == :no_match }    
  end
  
  # Determine if this filter matches the given DataFile or meta data hash
  def match data_file=nil, meta_data={}
    mt = data_file ? data_file.meta_data : meta_data
    parsed_expression.each do |key,value|                  
      if !mt[key] || !(mt[key] =~ /#{value}/i)
        return :no_match
      end
    end

    if negative
      return :negative_match
    else
      return :positive_match
    end    
  end
  
  # String representation of this filter
  def to_s
    parsed_expression.to_json
  end
  
  private
    
  # Deactivates any positive filter that matches a negative filter
  def deactivate_clashing_filters
    DataFileFilter.active.negative.each do |negative_filter|
      negative_filter.clashes.map(&:deactivate)
    end
  end
  
  # Prevent having two overlapping filters at the same time
  def no_duplicate_filters
    return true if !active
    DataFileFilter.find_all_by_active_and_negative(true,self.negative).each do |other|
      next if other.id == id # Skip myself
      if expression_clash? other
        errors.add(:expression, "must not conflict with other expressions. This on conflicts with '#{other.name}'")
      end
    end
    return true
  end
  
end
