# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  layout "default"
  
  before_filter :adjust_format_for_iphone
  
  private
  
  # Set iPhone format if request comes from iPhone
  def adjust_format_for_iphone
    request.format = :iphone if iphone_request?
  end
  
  # Return true for requests to iphone.trawlr.com
  def iphone_request?
    return params[:format] == "iphone"
  end
  
end
