class JobFoliosController < ApplicationController
  # GET /job_folios
  # GET /job_folios.json
  def index
    @job_folios = JobFolio.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @job_folios }
    end
  end

  # GET /job_folios/1
  # GET /job_folios/1.json
  def show
    @job_folio = JobFolio.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job_folio }
    end
  end

  # GET /job_folios/new
  # GET /job_folios/new.json
  def new
    @job_folio = JobFolio.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job_folio }
    end
  end

  # GET /job_folios/1/edit
  def edit
    @job_folio = JobFolio.find(params[:id])
  end

  # POST /job_folios
  # POST /job_folios.json
  def create
    @job_folio = JobFolio.new(params[:job_folio])

    respond_to do |format|
      if @job_folio.save
        format.html { redirect_to @job_folio, notice: 'Job folio was successfully created.' }
        format.json { render json: @job_folio, status: :created, location: @job_folio }
      else
        format.html { render action: "new" }
        format.json { render json: @job_folio.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /job_folios/1
  # PUT /job_folios/1.json
  def update
    @job_folio = JobFolio.find(params[:id])

    respond_to do |format|
      if @job_folio.update_attributes(params[:job_folio])
        format.html { redirect_to @job_folio, notice: 'Job folio was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @job_folio.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_folios/1
  # DELETE /job_folios/1.json
  def destroy
    @job_folio = JobFolio.find(params[:id])
    @job_folio.destroy

    respond_to do |format|
      format.html { redirect_to job_folios_url }
      format.json { head :ok }
    end
  end
end
