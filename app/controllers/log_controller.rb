class LogController < ApplicationController  
  def index
    begin
      @log_messages = File.read("log/scraper_#{Date.today}.log").split(/\r?\n/).reverse.join("\n")
    rescue
      @log_messages = ""
    end
  end
end