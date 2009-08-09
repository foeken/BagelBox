class DataFileFilter < ActiveRecord::Base
  
  belongs_to :source
  
  validates_presence_of :expression  
  validate :no_duplicate_filters

  def activate
    self.active = true
    save!
  end
  
  def deactivate
    self.active = false
    save!
  end
  
  def parsed_expression
    output = {}
    expression.scan(/(.*?):\"(.*?)\"/i).each do |label,value|
      output[label.to_sym] = value
    end
    return output
  end
  
  def self.match data_file=nil, meta_data={}, options={}
    filters = options[:include_inactive] ? DataFileFilter.all : DataFileFilter.find_all_by_active(true)
    return filters.reject{ |f| f.match(data_file,meta_data) == :no_match }    
  end
  
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
  
  def to_s
    parsed_expression.to_json
  end
  
  private
  
  def no_duplicate_filters
    return true if !active
    DataFileFilter.find_all_by_active(true).each do |other|

      next if other.id == id # Skip myself

      other_expression = other.parsed_expression
      my_expression    = parsed_expression

      # If I have less labels to worry about, then I am more generic. Thus I can be saved.
      if my_expression.keys.length < other_expression.keys.length
        next
      elsif my_expression.keys.length >= other_expression.keys.length && !(my_expression.keys & other_expression.keys).empty?
        # I have one or more the same labels as the other filter

        different = false
        my_expression.each do |key,value|
          if other_expression[key] && value != other_expression[key]
            different = true
            break
          end
        end

        next if different
        errors.add(:expression,"Must not conflict with other expressions. This on conflicts with '#{other.name}'")

      else
        # I have different keys.
        next
      end

    end
    return true
  end
  
end
