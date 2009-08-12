class SettingsController < ApplicationController
  # GET /settings
  # GET /settings.xml
  def index
    @settings          = Setting.all
    @scraper_installed = Scraper.installed?

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @settings }
    end
  end
  
  def install_scraper
    `rake scraper:install`
    redirect_to(settings_path)
  end
  
  def uninstall_scraper
    `rake scraper:uninstall`
    redirect_to(settings_path)
  end

  # GET /settings/new
  # GET /settings/new.xml
  def new
    @setting = Setting.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @setting }
    end
  end

  # GET /settings/1/edit
  def edit
    @setting = Setting.find(params[:id])
  end

  # POST /settings
  # POST /settings.xml
  def create
    @setting = Setting.new(params[:setting])

    respond_to do |format|
      if @setting.save
        flash[:notice] = 'Setting was successfully created.'
        format.html { redirect_to(settings_path) }
        format.xml  { render :xml => @setting, :status => :created, :location => @setting }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /settings/1
  # PUT /settings/1.xml
  def update
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update_attributes(params[:setting])
        flash[:notice] = 'Setting was successfully updated.'
        format.html { redirect_to(settings_path) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @setting.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /settings/1
  # DELETE /settings/1.xml
  def destroy
    @setting = Setting.find(params[:id])
    @setting.destroy

    respond_to do |format|
      format.html { redirect_to(settings_url) }
      format.xml  { head :ok }
    end
  end
end
