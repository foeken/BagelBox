class DataFileFiltersController < ApplicationController
  # GET /data_file_filters
  # GET /data_file_filters.xml
  def index
    @data_file_filters = DataFileFilter.all( :order => "active,negative,name" )

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @data_file_filters }
    end
  end

  # GET /data_file_filters/1
  # GET /data_file_filters/1.xml
  def show
    @data_file_filter = DataFileFilter.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @data_file_filter }
    end
  end

  # GET /data_file_filters/new
  # GET /data_file_filters/new.xml
  def new
    @data_file_filter = DataFileFilter.new
    @data_file_filter.active = true

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @data_file_filter }
    end
  end

  # GET /data_file_filters/1/edit
  def edit
    @data_file_filter = DataFileFilter.find(params[:id])
  end

  # POST /data_file_filters
  # POST /data_file_filters.xml
  def create
    @data_file_filter = DataFileFilter.new(params[:data_file_filter])

    respond_to do |format|
      if @data_file_filter.save
        flash[:notice] = 'DataFileFilter was successfully created.'
        format.html { redirect_to(data_file_filters_path) }
        format.xml  { render :xml => @data_file_filter, :status => :created, :location => @data_file_filter }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @data_file_filter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /data_file_filters/1
  # PUT /data_file_filters/1.xml
  def update
    @data_file_filter = DataFileFilter.find(params[:id])

    respond_to do |format|
      if @data_file_filter.update_attributes(params[:data_file_filter])
        flash[:notice] = 'DataFileFilter was successfully updated.'
        format.html { redirect_to(data_file_filters_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @data_file_filter.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /data_file_filters/1
  # DELETE /data_file_filters/1.xml
  def destroy
    @data_file_filter = DataFileFilter.find(params[:id])
    @data_file_filter.destroy

    respond_to do |format|
      format.html { redirect_to(data_file_filters_url) }
      format.xml  { head :ok }
    end
  end
end