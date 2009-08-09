class SourceTypes::SourceType  
  
  AVAILABLE = ["Rss","Ftp","Directory"]
    
  def self.name
    "SourceType"
  end
  
  def self.build source_type
    "SourceTypes::#{source_type}".constantize
  end
  
  def self.data location
    []
  end
      
end