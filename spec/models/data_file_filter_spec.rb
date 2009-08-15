require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DataFileFilter do
  
  before(:each) do
    DataFileFilter.delete_all
    DataFileFilter.create!( :expression => "title:\"Prison Break\"" )
  end
  
  it "should be able to list active filters" do
    DataFileFilter.active.should have(DataFileFilter.count).items
  end
  
  it "should be able to list negative filters" do
    DataFileFilter.all.map{ |d| d.update_attribute(:negative, true) }
    DataFileFilter.active.should have(DataFileFilter.count).items
  end
  
  it "should be able to list positive filters" do
    DataFileFilter.active.should have(DataFileFilter.count).items
  end
  
  it "should be able to deactivate/activate a filter" do
    filter = DataFileFilter.first  
    filter.deactivate
    DataFileFilter.active.should be_empty    
    filter.activate
    DataFileFilter.active.should_not be_empty    
  end
  
  it "should be able to determine if two filters clash" do
    filter       = DataFileFilter.first    
    other_filter = DataFileFilter.first.clone
        
    filter.expression_clash?(other_filter).should be_true
  
    filter.expression += "\r\nseason:\"4\""
    filter.expression_clash?(other_filter).should be_false
    other_filter.expression_clash?(filter).should be_true

  end
  
  it "should be able to parse the filter expression format into a hash" do
    DataFileFilter.first.parsed_expression.keys.should eql( [:title] )
    DataFileFilter.first.parsed_expression[:title].should eql( "Prison Break" )
  end
  
  it "should be able to determine if a data file matches itself" do
    DataFileFilter.first.match(nil, { :title => "Prison Break" }).should eql(:positive_match)
    DataFileFilter.first.match(nil, { :title => "Burn notice" }).should eql(:no_match)
    
    DataFileFilter.first.update_attribute(:negative,true)
    DataFileFilter.first.match(nil, { :title => "Prison Break" }).should eql(:negative_match)
  end
    
  it "should be able to determine if a data file matches any filter" do
    DataFileFilter.match(nil, { :title => "Prison Break" }).should eql( DataFileFilter.all )
    DataFileFilter.match(nil, { :title => "Burn notice" }).should be_empty
  end
  
  it "should not allow duplicate active filters of the same negativity state to be saved" do
    new_filter = DataFileFilter.first.clone    
    lambda{ new_filter.save! }.should raise_error
    
    new_filter = DataFileFilter.first.clone
    new_filter.negative = true
    lambda{ new_filter.save! }.should_not raise_error
    
    new_filter = DataFileFilter.first.clone
    new_filter.active = false
    lambda{ new_filter.save! }.should_not raise_error    
  end
  
  it "should deactivate any active positive filter that matches a negative filter" do
    negative = DataFileFilter.create!( :expression => "title:\"Prison Break\"", :negative => true )
    
    DataFileFilter.first.active.should be_false
    DataFileFilter.first.destroy
        
    DataFileFilter.create!( :expression => "title:\"Prison Break\"" )
    DataFileFilter.last.active.should be_false
    DataFileFilter.last.destroy
    
    DataFileFilter.create!( :expression => "title:\"Burn notice\"" )
    DataFileFilter.last.active.should be_true
    DataFileFilter.last.destroy
    
    DataFileFilter.create!( :expression => "title:\"Prison Break\"\r\nseason:\"04\"" )
    DataFileFilter.last.active.should be_false
    DataFileFilter.last.destroy
    
    DataFileFilter.create!( :expression => "title:\"Burn notice\"\r\nseason:\"04\"" )
    DataFileFilter.last.active.should be_true
    DataFileFilter.last.destroy
    
    negative.expression = "title:\"Prison Break\"\r\nseason:\"04\""
    negative.save!
        
    DataFileFilter.create!( :expression => "title:\"Prison Break\"" )
    DataFileFilter.last.active.should be_true
    DataFileFilter.last.destroy
    
    DataFileFilter.create!( :expression => "title:\"Prison Break\"\r\nseason:\"04\"" )
    DataFileFilter.last.active.should be_false
    DataFileFilter.last.destroy
        
    negative.update_attribute(:negative,false)
    
    DataFileFilter.create!( :expression => "title:\"Prison Break\"", :negative => true )
    DataFileFilter.first.active.should be_false
    DataFileFilter.last.active.should be_true
    
  end
  
end

