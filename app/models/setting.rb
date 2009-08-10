class Setting < ActiveRecord::Base
  def self.get key
    setting = Setting.find_by_key(key)
    if setting 
      return setting.value
    else 
      return nil
    end
  end
end
