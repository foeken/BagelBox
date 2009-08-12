# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  protect_from_forgery
  layout "default"
  
  before_filter :determine_format, :adjust_format_for_iphone
  
  private
  
  def determine_format
    if params[:format]
      session[:format] = params[:format]
    end
  end
  
  def adjust_format_for_iphone
    request.format = :iphone if session[:format] == "iphone"
  end
  
end
