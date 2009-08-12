class Setting < ActiveRecord::Base
  
  def self.wget_installed?
    return !(`wget 2>&1` =~ /Usage: wget/).nil?
  end
  
  def self.get key
    setting = Setting.find_by_key(key)
    if setting 
      return setting.value
    else 
      return nil
    end
  end
end
