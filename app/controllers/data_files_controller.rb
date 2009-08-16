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
    data_file = DataFile.find(params[:id])
    data_file.failed = false # Reset failed flag (for retries)
    data_file.queue_to_download
    data_file.source.start_downloading
    redirect_to(data_files_path)
  end
  
end