class DataFilesController < ApplicationController  
  def index
    @data_files = DataFile.all(:order => "downloaded_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.iphone # index.iphone.erb
      format.xml  { render :xml => @data_files }
    end
  end
  
  def download
    DataFile.find(params[:id]).download
    redirect_to(data_files_path)
  end
  
end