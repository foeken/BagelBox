class DataFilesController < ApplicationController  
  def index
    @data_files = DataFile.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @data_files }
    end
  end
end