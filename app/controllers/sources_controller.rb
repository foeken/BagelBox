class SourcesController < ApplicationController
  # GET /sources
  # GET /sources.xml
  def index
    @filter_sources  = Source.filter(  :order => "active,priority")
    @content_sources = Source.content( :order => "active,priority")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sources }
    end
  end

  # GET /sources/1
  # GET /sources/1.xml
  def show
    @source           = Source.find(params[:id])    
    @ignored_labels   = [:filename,:matcher,:category]
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @source }
    end
  end

  # GET /sources/new
  # GET /sources/new.xml
  def new
    @source = Source.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @source }
    end
  end

  # GET /sources/1/edit
  def edit
    @source = Source.find(params[:id])
  end
  
  def download    
    data_file_attributes = YAML.load(params[:data_file]).ivars["attributes"]
    data_file_attributes.delete("changed_attributes")
    data_file = DataFile.new(data_file_attributes)
    data_file.queue_to_download
    data_file.source.start_downloading      
    redirect_to(data_files_path)    
  end

  # POST /sources
  # POST /sources.xml
  def create    
    @source = Source.new(params[:source])
    
    respond_to do |format|
      if @source.save
        flash[:notice] = 'Source was successfully created.'
        format.html { redirect_to(sources_path) }
        format.xml  { render :xml => @source, :status => :created, :location => @source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sources/1
  # PUT /sources/1.xml
  def update
    @source = Source.find(params[:id])

    respond_to do |format|
      if @source.update_attributes(params[:source])
        flash[:notice] = 'Source was successfully updated.'
        format.html { redirect_to(sources_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.xml
  def destroy
    @source = Source.find(params[:id])
    @source.destroy

    respond_to do |format|
      format.html { redirect_to(sources_url) }
      format.xml  { head :ok }
    end
  end
end
