class DevFoliosController < ApplicationController
  # GET /dev_folios
  # GET /dev_folios.json
  def index
    @dev_folios = DevFolio.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dev_folios }
    end
  end

  # GET /dev_folios/1
  # GET /dev_folios/1.json
  def show
    begin
      @dev_folio = DevFolio.find(params[:id])
    rescue
      @dev_folio = DevFolio.where(label: params[:id]).first()
    end

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dev_folio }
    end
  end

  # GET /dev_folios/new
  # GET /dev_folios/new.json
  def new
    @dev_folio = DevFolio.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dev_folio }
    end
  end

  # GET /dev_folios/1/edit
  def edit
    @dev_folio = DevFolio.find(params[:id])
  end
  
  # GET /dev_folios/1/export
  def export
    @dev_folio = DevFolio.find(params[:id])
    # get latest folio contents as zip file
  end

  # POST /dev_folios
  # POST /dev_folios.json
  def create
    @dev_folio = DevFolio.new(params[:dev_folio])

    respond_to do |format|
      if @dev_folio.save
        format.html { redirect_to @dev_folio, notice: 'Dev folio was successfully created.' }
        format.json { render json: @dev_folio, status: :created, location: @dev_folio }
      else
        format.html { render action: "new" }
        format.json { render json: @dev_folio.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # PUT /dev_folios/1/push
  # PUT /dev_folios/1/push.json
  def push
    begin
      @dev_folio = DevFolio.find(params[:id])
    rescue
      @dev_folio = DevFolio.where(label: params[:id]).first()
    end
    
    respond_to do |format|
      if @dev_folio.push_repo
        format.html { redirect_to @dev_folio, notice: 'Dev folio was successfully pushed to git repo.' }
        format.json { head :ok }
      else
        format.html { render action: "show" }
        format.json { render json: @dev_folio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dev_folios/1
  # PUT /dev_folios/1.json
  def update
    @dev_folio = DevFolio.find(params[:id])

    respond_to do |format|
      if @dev_folio.update_attributes(params[:dev_folio])
        format.html { redirect_to @dev_folio, notice: 'Dev folio was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @dev_folio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dev_folios/1
  # DELETE /dev_folios/1.json
  def destroy
    @dev_folio = DevFolio.find(params[:id])
    @dev_folio.destroy

    respond_to do |format|
      format.html { redirect_to dev_folios_url }
      format.json { head :ok }
    end
  end
end
