class DataType < ActiveRecord::Base
  
  FILENAME_WHITESPACE_REPLACEMENTS = "[._-]"
  MATCHER_SPLITTER = "\r?\n"
  REGEX_SPLITTER   = "~"
  LABEL_SPLITTER   = ","
  CATEGORIES       = ["movie","tv_show"]
  
  has_many :data_files, :dependent => :destroy
    
  def self.for filename
    DataType.all(:order => "extension DESC").each do |data_type|
      return data_type if filename =~ /#{data_type.extension}/
    end
    return nil
  end
  
  def get_definition variable
    meta_matchers_with_includes([self],:skip_definitions => true).scan(/define #{variable}, "(.*)"/).flatten.first
  end
  
  def meta_matchers_with_defines
    output         = meta_matchers.clone
    define_matches = output.scan(/define (.*?), "(.*)"/)
    define_matches.each do |variable,value|
      output.gsub!(/define #{variable}, "#{Regexp.escape(value)}"(\r\n)?/, "")
      output.gsub!(/#{variable}/,value)
    end
    return output
  end
  
  def meta_matchers_with_includes already_included=[self], options={}
    output          = options[:skip_definitions] ? meta_matchers.clone : meta_matchers_with_defines
    include_matches = output.scan(/include "(.*)"/)    
    if !include_matches.empty?
      include_matches.each do |data_type_name|
        dt = DataType.find_by_name(data_type_name)        
        if dt
          # Make sure we prevent circular references
          if !already_included.include?(dt)
            dt_matchers = dt.meta_matchers_with_includes(already_included,options)
            dt_matchers = "# BEGIN INCLUDE: \"#{data_type_name}\"\r\n" + dt_matchers
            dt_matchers = dt_matchers + "\r\n# END INCLUDE: \"#{data_type_name}\""
            output.gsub!(/include "#{data_type_name}"/,dt_matchers)
            already_included << dt
          else
            output.gsub!(/include "#{data_type_name}"/,"# Skipped include \"#{data_type_name}\"")
          end
        else
          SCRAPER_LOG.error( "Could not include file type: #{data_type_name} in #{self.name}" )
        end
      end
    end
    return output
  end
  
  def meta_data data_file
    labelled_matches = { :filename => data_file.filename }    
    
    if data_file.directory && data_file.directory != "."
      filename = "#{data_file.directory}/#{data_file.filename}"
    else
      filename = data_file.filename
    end

    meta_matchers_with_includes.split(/#{MATCHER_SPLITTER}/).each_with_index do |matcher,i|      
      next if matcher.blank? || matcher.starts_with?('#') # Allow blank lines and comments
      regex    = matcher.split(/#{REGEX_SPLITTER}/).first
      labels   = matcher.split(/#{REGEX_SPLITTER}/).last.split(/#{LABEL_SPLITTER}/)
      matcher  = filename.match(/#{regex}/i)
      captures = matcher.captures if matcher
      if captures && !captures.empty?
        # Store matcher for ease of use
        labelled_matches[:matcher] = { :index => i, :regex => regex, :labels => labels }
        labels.each_with_index do |label,j|          
          value   = captures[j].gsub(/#{FILENAME_WHITESPACE_REPLACEMENTS}/,' ').strip
          current = labelled_matches[label.to_sym]
          
          # If a value has been set we add it to an array of values
          if current
            if current.is_a?(Array)
              value = current + [value]
            else
              value = [current,value]
            end
            value.uniq!
          end
          
          labelled_matches[label.to_sym] = value
        end
        
        labelled_matches[:category] = data_file.category(labelled_matches).to_s
        return labelled_matches
        
      end
    end
    
    labelled_matches[:category] = data_file.category(labelled_matches).to_s
    
    return labelled_matches
  end
    
end
